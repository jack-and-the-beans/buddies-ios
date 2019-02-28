//
//  DataAccessor.swift
//  Buddies
//
//  Created by Jake Thurman on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

// Helpers...
typealias Canceler = () -> Void
class Listener<T> {
    let fn: (T?) -> Void
    init(fn: @escaping (T?) -> Void) {
        self.fn = fn
    }
}

typealias RegisterAuthStateListener = (@escaping AuthStateDidChangeListenerBlock)->AuthStateDidChangeListenerHandle

// !----------------------------------------------!
// ! See example usage in Profile/ProfileVC.swift !
// !----------------------------------------------!
class DataAccessor : LoggedInUserInvalidationDelegate, ActivityInvalidationDelegate {
    static let instance = DataAccessor(
        usersCollection: Firestore.firestore().collection("users"),
        accountCollection: Firestore.firestore().collection("accounts"),
        activitiesCollection: Firestore.firestore().collection("activities"))
    
    let usersCollection: CollectionReference
    let accountCollection: CollectionReference
    let activitiesCollection: CollectionReference
    
    var cancelAuthStateListener: Canceler?
    let storageManager: StorageManager
    
    init(usersCollection: CollectionReference,
         accountCollection: CollectionReference,
         activitiesCollection: CollectionReference,
         storageManager: StorageManager = StorageManager.shared,
         addChangeListener: RegisterAuthStateListener = Auth.auth().addStateDidChangeListener,
         removeChangeListener: @escaping (AuthStateDidChangeListenerHandle) -> Void = Auth.auth().removeStateDidChangeListener) {
        self.usersCollection = usersCollection
        self.accountCollection = accountCollection
        self.activitiesCollection = activitiesCollection
        self.storageManager = storageManager
        
        // Register to interally listen to the logged in user.
        initLoggedInUserListener(addChangeListener, removeChangeListener)
    }
    
    func initLoggedInUserListener(_ addChangeListener: RegisterAuthStateListener, _ removeChangeListener: @escaping (AuthStateDidChangeListenerHandle) -> Void) {
        var lastCanceler: Canceler?

        let handle = addChangeListener { _, user in
            lastCanceler?()
            self._loggedInUserRegistration?.remove()
            self._cachedLoggedInUser = nil
            self._loggedInUID = user?.uid
            lastCanceler = self.useLoggedInUser { self._cachedLoggedInUser = $0 }
        }
        
        self.cancelAuthStateListener = {
            removeChangeListener(handle)
        }
    }
    
    var _loggedInUserListeners: [Listener<LoggedInUser>] = []
    var _userListeners: [UserId : [Listener<User>]] = [:]
    var _activityListeners: [ActivityId : [Listener<Activity>]] = [:]
    
    var _loggedInUserRegistration: ListenerRegistration?
    var _userRegistration: [UserId : ListenerRegistration] = [:]
    var _activityRegistration: [ActivityId : ListenerRegistration] = [:]
    
    let _userCache = NSCache<AnyObject/*UserId*/, OtherUser>()
    let _activityCache = NSCache<AnyObject/*ActivityId*/, Activity>()
    
    var _loggedInUID: String?
    var _cachedLoggedInUser: LoggedInUser?
    
    // To deduplicate requests!
    var _usersLoading: [UserId] = []
    var _activitiesLoading: [ActivityId] = []
    
    deinit {
        _userRegistration.values.forEach { $0.remove() }
        _activityRegistration.values.forEach { $0.remove() }
        _loggedInUserRegistration?.remove()
        
        self.cancelAuthStateListener?()
    }
    
    func isUserCached(id: UserId) -> Bool {
        if id == _loggedInUID {
            return _loggedInUID != nil
        }
        return _userCache.object(forKey: id as AnyObject) != nil
    }
    
    
    func useLoggedInUser(fn: @escaping (LoggedInUser?) -> Void) -> Canceler {
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        _loggedInUserListeners.append(callback)
        
        // Handle calling the callback
        if let user = _cachedLoggedInUser {
            callback.fn(user)
        }
        else if _loggedInUID == nil {
            callback.fn(nil)
        }
        else {
            self._loadLoggedInUser()
        }
        
        // Return a cancel callback
        return {
            self._loggedInUserListeners = self._loggedInUserListeners.filter {$0 !== callback}
        }
    }
    
    func _loadLoggedInUser() {
        guard let uid = self._loggedInUID else { return }
        
        _loggedInUserRegistration = usersCollection.document(uid).addSnapshotListener {
            guard let snap = $0 else {
                print($1!)
                return
            }
            guard let user = LoggedInUser.from(snap: snap, with: self) else {
                print("VERY BAD: invalid account ID=\"\(uid)\"")
                return
            }
            
            self.storageManager.getImage(imageUrl: user.imageUrl, localFileName: user.uid) { img in
                user.image = img
            }
            
            self._usersLoading.removeAll(where: { $0 == uid })
            
            self.onInvalidateLoggedInUser(user: user)
        }
    }
    
    func useUsers(from userIds: [String], fn: @escaping ([User]) -> Void) -> Canceler {
        let numUsersNeeded = userIds.count
        var users: [UserId: User] = [:]
        let cb = {
            var allUsers: [User] = []
            for (_, user) in users {
                allUsers.append(user)
            }
            // This avoids the case where we re-update the view again and again
            // for each user ID in the initial array. We instead wait to update
            // until all of the users have been initially populated, and then
            // subsequently on any change to any user.
            if (allUsers.count == numUsersNeeded) {
                fn(allUsers)
            }
        }
        let cancelers = userIds.map { useUser(id: $0) { user in
            if let user = user {
                users[user.uid] = user
                cb()
            }
        } }
        return { for c in cancelers { c() } }
    }
    
    func useUser(id: UserId, fn: @escaping (User?) -> Void) -> Canceler {
        // If this is for the logged in user, translate.
        if id == _loggedInUID {
            return useLoggedInUser(fn: fn)
        }
        
        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if _userListeners[id] == nil { _userListeners[id] = [] }
        _userListeners[id]?.append(callback)
        
        // Handle calling the callback
        if let user = _userCache.object(forKey: id as AnyObject) {
            callback.fn(user)
            
            // If we removed the listener, add it back
            if _userRegistration[id] == nil {
                self._loadUser(id: id)
            }
        }
        else if !_usersLoading.contains(id) {
            _usersLoading.append(id)
            
            self._loadUser(id: id)
        }
    
        // Return a cancel callback
        return {
            self._userListeners[id] = self._userListeners[id]?.filter {
                $0 !== callback
            }
            
            // If there are no listeners, stop listening to firebase
            if self._userListeners[id]?.isEmpty ?? true,
                let reg = self._userRegistration[id] {
                reg.remove()
            }
        }
    }
    
    func _loadUser(id: UserId) {
        if let oldReg = _userRegistration[id] {
            oldReg.remove()
        }

        _userRegistration[id] = usersCollection.document(id).addSnapshotListener {
            guard let snap = $0 else {
                print($1!)
                return
            }
            
            guard let user = OtherUser.from(snap: snap) else {
                print("invalid user :( \(id)")
                return
            }
            
            self.storageManager.getImage(imageUrl: user.imageUrl, localFileName: user.uid) { img in
                user.image = img
                self.onInvalidateUser(user: user)
            }

            self._usersLoading.removeAll(where: { $0 == id })
            
            self.onInvalidateUser(user: user)
        }
    }
    
    func useActivity(id: ActivityId, fn: @escaping (Activity?) -> Void) -> (() -> Void) {
        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if _activityListeners[id] == nil { _activityListeners[id] = [] }
        _activityListeners[id]?.append(callback)
        
        // Handle calling the callback
        if let activity = _activityCache.object(forKey: id as AnyObject) {
            callback.fn(activity)
            
            // If we removed the firebase listener, add it back
            if _activityRegistration[id] == nil {
                self._loadActivity(id: id)
            }
        }
        else if !_activitiesLoading.contains(id) {
            _activitiesLoading.append(id)
            
            self._loadActivity(id: id)
        }
        
        // Return a cancel callback
        return {
            self._activityListeners[id] = self._activityListeners[id]?.filter {
                $0 !== callback
            }
            
            // If there are no listeners, stop listening to firebase
            if self._activityListeners[id]?.isEmpty ?? true,
                let reg = self._activityRegistration[id] {
                reg.remove()
            }
        }
    }
    
    func _loadActivity(id: ActivityId) {
        if let oldReg = _activityRegistration[id] {
            oldReg.remove()
        }
        
        _activityRegistration[id] = activitiesCollection.document(id).addSnapshotListener {
            guard let snap = $0 else {
                print($1!)
                return
            }
            
            let activity = Activity.from(snap: snap, with: self)
            
            self._activitiesLoading.removeAll(where: { $0 == id })
            
            self.onInvalidateActivity(activity: activity, id: id)
        }
    }
    
    
    func onInvalidateUser(user: OtherUser) {
        _userCache.setObject(user, forKey: user.uid as AnyObject)
        
        _userListeners[user.uid]?.forEach { $0.fn(user) }
    }
    
    // MARK: LoggedInUserInvalidationDelegate
    func onInvalidateLoggedInUser(user: LoggedInUser?) {
        _cachedLoggedInUser = user
        _loggedInUserListeners.forEach { $0.fn(user) }
    }
    
    func triggerServerUpdate(userId: UserId, key: String, value: Any?) {
        let doc = usersCollection.document(userId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
    
    // MARK: ActivityInvalidationDelegate
    func onInvalidateActivity(activity: Activity?, id: String) {
        if let updatedActivity = activity {
            _activityCache.setObject(updatedActivity, forKey: updatedActivity.activityId as AnyObject)
        } else {
            // Activity was deleted, or is invalid:
            _activityCache.removeObject(forKey: id as AnyObject)
        }
        _activityListeners[id]?.forEach { $0.fn(activity) }
    }
    
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?) {
        let doc = activitiesCollection.document(activityId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
}
