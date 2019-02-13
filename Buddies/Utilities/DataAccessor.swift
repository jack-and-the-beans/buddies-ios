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
    static let instance = DataAccessor()
    
    var _userListeners: [UserId : [Listener<User>]] = [:]
    var _activityListeners: [ActivityId : [Listener<Activity>]] = [:]
    
    var _userRegistration: [UserId : ListenerRegistration] = [:]
    var _activityRegistration: [ActivityId : ListenerRegistration] = [:]
    
    let _userCache = NSCache<AnyObject/*UserId*/, User>()
    let _activityCache = NSCache<AnyObject/*ActivityId*/, Activity>()
    
    // To deduplicate requests!
    var _usersLoading: [UserId] = []
    var _activitiesLoading: [ActivityId] = []
    
    func useUser(id: UserId, fn: @escaping (User) -> Void) -> (() -> Void) {
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
                _userRegistration[id] = self._loadUser(id: id)
            }
        }
        else if !_usersLoading.contains(id) {
            _usersLoading.append(id)
            
            _userRegistration[id] = self._loadUser(id: id)
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
    
    func _loadUser(id: UserId, users: CollectionReference = Firestore.firestore().collection("users")) -> ListenerRegistration {
        return users.document(id).addSnapshotListener {
            guard let snap = $0 else {
                print($1!)
                return
            }
            
            guard let user = User.from(snap: snap, with: self) else {
                print("invalid user :( \(id)")
                return
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
                _activityRegistration[id] = self._loadActivity(id: id)
            }
        }
        else if !_activitiesLoading.contains(id) {
            _activitiesLoading.append(id)
            
            _activityRegistration[id] = self._loadActivity(id: id)
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
    
    func _loadActivity(id: ActivityId,activities: CollectionReference = Firestore.firestore().collection("activities")) -> ListenerRegistration {
        return activities.document(id).addSnapshotListener {
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
    
    // MARK: ActivityInvalidationDelegate
    func onInvalidateActivity(activity: Activity) {
        _activityCache.setObject(activity, forKey: activity.activityId as AnyObject)
        
        _activityListeners[activity.activityId]?.forEach { $0.fn(activity) }
    }
}
