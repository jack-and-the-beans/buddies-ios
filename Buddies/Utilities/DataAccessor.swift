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
            
            self._loginStateLoaded = true
            
            // Trigger an invalidation if we're logged out.
            //  this is due to the messy way that this works.
            if let _ = user { self._cachedLoggedInUser = nil }
            else { self.onInvalidateLoggedInUser(user: nil) }
            
            self._loggedInUID = user?.uid
            lastCanceler = self.useLoggedInUser { self._cachedLoggedInUser = $0 }
            
        }
        
        self.cancelAuthStateListener = {
            removeChangeListener(handle)
        }
    }
    
    var _loginStateLoaded = false
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
            if _loginStateLoaded {
                callback.fn(nil)
            }
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
        
        _loggedInUserRegistration?.remove()
        
        _loggedInUserRegistration = accountCollection.document(uid).addSnapshotListener {
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
    
    // Callback will not include users who DNE
    func useUsers(from userIds: [String], fn: @escaping ([User]) -> Void) -> Canceler {
        var handledUsers: [UserId: Bool] = [:]
        var users = [User]()
        var didFinishSetup = false
        let cancelers = userIds.map { uid in useUser(id: uid) { user in
            if let user = user, handledUsers[uid] == nil {
                users.append(user)
                handledUsers[uid] = true
            } else if handledUsers[uid] == nil {
                // DNE yet, but the user doesn't exist either:
                handledUsers[uid] = false
            } else if let user = user {
                // Exists, so we want to update this user.
                if let index = users.firstIndex(where: { $0.uid == uid }) {
                    users[index] = user
                    fn(users)
                }
            } else {
                // Used to exist, but we need to remove it now.
                fn( users.filter { $0.uid != uid } )
            }
            if (handledUsers.count == userIds.count && !didFinishSetup) {
                didFinishSetup = true
                fn(users)
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
                _usersLoading.append(id)
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
        }
    }
    
    func _loadUser(id: UserId) {
        // If the user registration already exists, no need to set it up again:
        guard _userRegistration[id] == nil else { return }

        _userRegistration[id] = usersCollection.document(id).addSnapshotListener { snap, err in
            var user: OtherUser?
            
            if let snap = snap {
                user = OtherUser.from(snap: snap)
                if let user = user {
                    self.storageManager.getImage(imageUrl: user.imageUrl, localFileName: user.uid) { img in
                        user.image = img
                        self.onInvalidateUser(user: user)
                    }
                }
            } else if let err = err {
                print(err)
            }

            // We want to remove and invalidate, even
            // if getting the user failed:
            self._usersLoading.removeAll(where: { $0 == id })
            
            self.onInvalidateUser(user: user, id: id)
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
        }
    }
    
    // Returns a canceler for the user listeners
    // for the activity
    func _loadActivity(id: ActivityId) {
        // Use the existing registration if one exists:
        guard _activityRegistration[id] == nil else { return }

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
    
    // If user is nil, we can use the given id
    // to call the listeners
    func onInvalidateUser(user: OtherUser?, id: UserId? = nil) {
        if let user = user {
            _userCache.setObject(user, forKey: user.uid as AnyObject)
            _userListeners[user.uid]?.forEach { $0.fn(user) }
        } else if let uid = id {
            _userListeners[uid]?.forEach { $0.fn(user) }
        }
    }
    
    // MARK: LoggedInUserInvalidationDelegate
    func onInvalidateLoggedInUser(user: LoggedInUser?) {
        _cachedLoggedInUser = user
        _loggedInUserListeners.forEach { $0.fn(user) }
    }
    
    func triggerServerUpdate(userId: UserId, key: String, value: Any?) {
        let doc = accountCollection.document(userId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
    
    // MARK: ActivityInvalidationDelegate
    func onInvalidateActivity(activity: Activity?, id: String) {
        if let updatedActivity = activity {
            _activityCache.setObject(updatedActivity, forKey: updatedActivity.activityId as AnyObject)
            _activityListeners[id]?.forEach { $0.fn(updatedActivity) }
        } else {
            // Activity was deleted, or is invalid:
            _activityCache.removeObject(forKey: id as AnyObject)
            _activityListeners[id]?.forEach { $0.fn(activity) }
        }
    }
    
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?) {
        let doc = activitiesCollection.document(activityId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
}
