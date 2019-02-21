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
    let fn: (T) -> Void
    init(fn: @escaping (T) -> Void) {
        self.fn = fn
    }
}

// !----------------------------------------------!
// ! See example usage in Profile/ProfileVC.swift !
// !----------------------------------------------!
class DataAccessor : UserInvalidationDelegate, ActivityInvalidationDelegate {
    static let instance = DataAccessor(
        usersCollection: Firestore.firestore().collection("users"),
        activitiesCollection: Firestore.firestore().collection("activities"))
    
    let usersCollection: CollectionReference
    let activitiesCollection: CollectionReference
    
    init(usersCollection: CollectionReference, activitiesCollection: CollectionReference) {
        self.usersCollection = usersCollection
        self.activitiesCollection = activitiesCollection
    }
    
    var _userListeners: [UserId : [Listener<User>]] = [:]
    var _activityListeners: [ActivityId : [Listener<Activity>]] = [:]
    
    var _userRegistration: [UserId : ListenerRegistration] = [:]
    var _activityRegistration: [ActivityId : ListenerRegistration] = [:]
    
    let _userCache = NSCache<AnyObject/*UserId*/, User>()
    let _activityCache = NSCache<AnyObject/*ActivityId*/, Activity>()
    
    // To deduplicate requests!
    var _usersLoading: [UserId] = []
    var _activitiesLoading: [ActivityId] = []
    
    deinit {
        _userRegistration.values.forEach { $0.remove() }
        _activityRegistration.values.forEach { $0.remove() }
    }
    
    func isUserCached(id: UserId) -> Bool {
        return _userCache.object(forKey: id as AnyObject) != nil
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
            users[user.uid] = user
            cb()
        } }
        return { for c in cancelers { c() } }
    }

    func useUser(id: UserId, fn: @escaping (User) -> Void) -> Canceler {
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
    
    func _loadUser(id: UserId, storageManager: StorageManager = StorageManager.shared) {
        if let oldReg = _userRegistration[id] {
            oldReg.remove()
        }

        _userRegistration[id] = usersCollection.document(id).addSnapshotListener {
            guard let snap = $0 else {
                print($1!)
                return
            }
            
            guard let user = User.from(snap: snap, with: self) else {
                print("invalid user :( \(id)")
                return
            }
            
            storageManager.getImage(imageUrl: user.imageUrl, localFileName: user.uid) { img in
                user.image = img
                self.onInvalidateUser(user: user)
            }

            self._usersLoading.removeAll(where: { $0 == id })
            
            self.onInvalidateUser(user: user)
        }
    }
    
    func useActivity(id: ActivityId, fn: @escaping (Activity) -> Void) -> (() -> Void) {
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
            
            guard let activity = Activity.from(snap: snap, with: self) else {
                print("invalid activity :( \(id)")
                return
            }
            
            self._activitiesLoading.removeAll(where: { $0 == id })
            
            self.onInvalidateActivity(activity: activity)
        }
    }
    
    
    // MARK: UserInvalidationDelegate
    func onInvalidateUser(user: User) {
        _userCache.setObject(user, forKey: user.uid as AnyObject)
        
        _userListeners[user.uid]?.forEach { $0.fn(user) }
    }
    
    func triggerServerUpdate(userId: UserId, key: String, value: Any?) {
        let doc = usersCollection.document(userId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
    
    // MARK: ActivityInvalidationDelegate
    func onInvalidateActivity(activity: Activity) {
        _activityCache.setObject(activity, forKey: activity.activityId as AnyObject)
        
        _activityListeners[activity.activityId]?.forEach { $0.fn(activity) }
    }
    
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?) {
        let doc = activitiesCollection.document(activityId)
        
        if let value = value {
            doc.setData([ key: value ], merge: true)
        }
    }
}
