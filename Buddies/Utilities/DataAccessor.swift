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
            lastCanceler = self.useLoggedInUser { newUser in
                let oldUser = self._cachedLoggedInUser
                // Default to true because we'd be going from nil to something, which is a change:
                let isActivityBlockListDifferent = oldUser?.isActivityBlockListDifferent(newUser) ?? true
                let isUserBlockListDifferent = oldUser?.isUserBlockListDifferent(newUser) ?? true
                
                self._cachedLoggedInUser = newUser
                if (isActivityBlockListDifferent || isUserBlockListDifferent) {
                    self.handleBlockListChange(newUser, handleUsers: isUserBlockListDifferent, handleActivities: isActivityBlockListDifferent)
                }
            }
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
    
    deinit {
        _userRegistration.values.forEach { $0.remove() }
        _activityRegistration.values.forEach { $0.remove() }
        _loggedInUserRegistration?.remove()
        
        self.cancelAuthStateListener?()
    }
    
    func isUserCached(id: UserId) -> Bool {
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
                if let err = $1 {
                    print("BAD: Logged in user did NOT load for some reason", err)
                    self.onInvalidateLoggedInUser(user: nil)
                }
                return
            }
            guard let user = LoggedInUser.from(snap: snap, with: self) else {
                print("VERY BAD: invalid account ID=\"\(uid)\"")
                self.onInvalidateLoggedInUser(user: nil)
                return
            }
            
            self.storageManager.getImage(imageUrl: user.imageUrl, localFileName: "\(user.uid)_\(user.imageVersion)") { img in
                user.image = img
            }
            
            self.onInvalidateLoggedInUser(user: user)
        }
    }
    
    // Callback will not include users who DNE
    func useUsers(from userIds: [String], fn: @escaping ([User]) -> Void) -> Canceler {
        // If a user ID is in this, we've loaded it initially
        // The boolean tracks if it exists or if it's nil
        var handledUsers: [UserId: Bool] = [:]
        var users = [User]()
        var didFinishSetup = false
        let cancelers = userIds.map { uid in useUser(id: uid) { user in
            if let user = user, handledUsers[uid] == nil {
                // User is not loaded yet, and the user exists
                users.append(user)
                handledUsers[uid] = true
            } else if handledUsers[uid] == nil {
                // Is not loaded yet, and the user doesn't exist either:
                handledUsers[uid] = false
            } else if let user = user {
                // The user has been loaded, so we want to update this user.
                if let index = users.firstIndex(where: { $0.uid == uid }) {
                    users[index] = user
                    if (didFinishSetup) {
                        fn(users)
                    }
                }
            } else {
                // Used to exist, but we need to remove it now.
                users = users.filter { $0.uid != uid }
                if (didFinishSetup) {
                    fn(users)
                }
            }
            if (handledUsers.count == userIds.count && !didFinishSetup) {
                didFinishSetup = true
                fn(users)
            }
        } }
        return { for c in cancelers { c() } }
    }
    
    func useUser(id: UserId, fn: @escaping (User?) -> Void) -> Canceler {
        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if _userListeners[id] == nil { _userListeners[id] = [] }
        _userListeners[id]?.append(callback)

        // Immediately post back update if we have info cached:
        if (_cachedLoggedInUser?.isBlocked(user: id) ?? false) {
            callback.fn(nil)
        } else if let user = _userCache.object(forKey: id as AnyObject) {
            callback.fn(user)
        }
        
        // Makes sure that firebase listener is set up:
        self._loadUser(id: id)
        
        // Return a cancel callback
        return {
            self._userListeners[id] = self._userListeners[id]?.filter {
                $0 !== callback
            }
        }
    }
    
    func _loadUser(id: UserId) {
        // If there's a previous registration, remove it:
        if let reg = _userRegistration[id] {
            reg.remove()
        }

        _userRegistration[id] = usersCollection.document(id).addSnapshotListener { snap, err in
            guard let snap = snap else {
                if let err = err {
                    print("BAD: Could not load a user's snapshot", err)
                }
                self.onInvalidateUser(user: nil, id: id)
                return
            }
            
            if let user = OtherUser.from(snap: snap) {
            	self.storageManager.getImage(imageUrl: user.imageUrl, localFileName: "\(user.uid)_\(user.imageVersion)") { img in
                    user.image = img
                    self.onInvalidateUser(user: user)
                }
                self.onInvalidateUser(user: user, id: id)
            } else {
                self.onInvalidateUser(user: nil, id: id)
            }
        }
    }
    
    func useActivity(id: ActivityId, fn: @escaping (Activity?) -> Void) -> (() -> Void) {
        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if _activityListeners[id] == nil { _activityListeners[id] = [] }
        _activityListeners[id]?.append(callback)

        // If it exists in the cache, immediately post back to the listener
        if let activity = _activityCache.object(forKey: id as AnyObject) {
            if (_cachedLoggedInUser?.isBlocked(activity: activity) ?? false) {
                callback.fn(nil)
            } else {
                callback.fn(activity)
            }
        }

        // Make sure firebase listener is set up:
        self._loadActivity(id: id)
        
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
        // If there's a previous registration, remove it:
        if let reg = _activityRegistration[id] {
            reg.remove()
        }

        // Always re-initiate the snapshot listener so that we get changes immediately:
        _activityRegistration[id] = activitiesCollection.document(id).addSnapshotListener {
            guard let snap = $0 else {
                if let error = $1 {
                    print("BAD: error loading activity", error)
                }
                self.onInvalidateActivity(activity: nil, id: id)
                return
            }
            
            let activity = Activity.from(snap: snap, with: self)
            
            self.onInvalidateActivity(activity: activity, id: id)
        }
    }
    
    // If user is nil, we can use the given id to call the listeners
    func onInvalidateUser(user: OtherUser?, id: UserId? = nil) {
        let uid = user?.uid ?? id
        // Handle cache:
        if let user = user {
            _userCache.setObject(user, forKey: user.uid as AnyObject)
        } else if let id = uid {
            _userCache.removeObject(forKey: id as AnyObject)
        }

        let isBlocked = _cachedLoggedInUser?.isBlocked(user: id) ?? false
        if let uid = uid, (isBlocked || user == nil) {
            // If the user is blocked or if it does not exist:
            _userListeners[uid]?.forEach { $0.fn(nil) }
        } else if let user = user, !isBlocked {
            // Otherwise use the actual data:
            _userListeners[user.uid]?.forEach { $0.fn(user) }
        }
    }
    
    // MARK: LoggedInUserInvalidationDelegate
    func onInvalidateLoggedInUser(user: LoggedInUser?) {
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
        // Update activity
        if let updatedActivity = activity {
            _activityCache.setObject(updatedActivity, forKey: updatedActivity.activityId as AnyObject)
        } else {
            // Activity was deleted, or is invalid:
            _activityCache.removeObject(forKey: id as AnyObject)
        }
        // Call listeners:
        let isBlocked = _cachedLoggedInUser?.isBlocked(activity: activity) ?? false
        if (isBlocked || activity == nil) {
            // Case where the activity is either blocked or does not exist
            _activityListeners[id]?.forEach { $0.fn(nil) }
        } else if let activity = activity, !isBlocked {
            // Case where the activity exists and is not blocked:
            _activityListeners[id]?.forEach { $0.fn(activity) }
        }
    }
    
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?) {
        let doc = activitiesCollection.document(activityId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
    
    func handleBlockListChange(_ user: LoggedInUser?, handleUsers: Bool, handleActivities: Bool) {
        guard let user = user else { return }
        
        if (handleUsers) {
            user.userBlockList.forEach { id in
                _userListeners[id]?.forEach { $0.fn(nil) }
            }
        }

        if (handleActivities || handleUsers) {
            _activityListeners.keys.forEach { key in
                self._loadActivity(id: key)
            }
        }
    }
}
