//
//  DataAccessor.swift
//  Buddies
//
//  Created by Jake Thurman on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

typealias Canceler = () -> Void
class Listener<T> {
    let fn: (T) -> Void
    init(fn: @escaping (T) -> Void) {
        self.fn = fn
    }
}

class DataAccessor : UserInvalidationDelegate, ActivityInvalidationDelegate {
    static let instance = DataAccessor()
    
    var userListeners: [UserId : [Listener<User>]] = [:]
    var activityListeners: [ActivityId : [Listener<Activity>]] = [:]
    
    func useUser(id: UserId, fn: @escaping (User) -> Void) -> (() -> Void) {
        // TEMP
        let testUser = User(delegate: self, imageUrl: "https://firebasestorage.googleapis.com/v0/b/beans-buddies.appspot.com/o/users%2F0VGQuKhyutT9YN12mobZauv6gtx2%2FprofilePicture.jpg?alt=media&token=1bc36e80-e3bb-4fbe-9444-50937651c3bd", isAdmin: true, uid: "n5vz1YkFqiP2IJ5rYDCEGve3QlG2", name: "Luke the Dummy", bio: "Hello blah blah blah bio", email: "noahtallen@waitImLuke.com", facebookId: nil, favoriteTopics: [], blockedUsers: [], blockedBy: [], blockedActivities: [], dateJoined: Date(), location: nil, shouldSendJoinedActivityNotification: true, shouldSendActivitySuggestionNotification: true, notificationToken: nil, chatReadAt: [:])
        
        
        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if userListeners[id] == nil { userListeners[id] = [] }
        userListeners[id]?.append(callback)
        
        // Call the function initially,
        //  TODO: load actual user data
        callback.fn(testUser)
    
        // Return a cancel callback
        return {
            self.userListeners[id] = self.userListeners[id]?.filter {
                $0 !== callback
            }
        }
    }
    
    func useActivity(id: ActivityId, fn: @escaping (Activity) -> Void) -> (() -> Void) {
        // TEMP
        let testActivity = Activity(delegate: self, activityId: "0LtIRbcC92irk3jYcjWg", dateCreated: Date(), members: ["n5vz1YkFqiP2IJ5rYDCEGve3QlG2"], location: GeoPoint(latitude: 37.376272812760504, longitude: -122.03007651230622), ownerId: "n5vz1YkFqiP2IJ5rYDCEGve3QlG2", title: "Do stuff", description: "please do stuff with me", startTime: Date(), endTime: Date(), topicIds: ["FO5Eg18UeGpcqeiCD4KB"])

        // Wrap the callback for comparison later
        let callback = Listener(fn: fn)
        
        // Insert it into the set of listeners
        if activityListeners[id] == nil { activityListeners[id] = [] }
        activityListeners[id]?.append(callback)
        
        // Call the function initially,
        //  later this will be after loading the user
        callback.fn(testActivity)
        
        // Return a cancel callback
        return {
            self.activityListeners[id] = self.activityListeners[id]?.filter {
                $0 !== callback
            }
        }
    }
    
    func onInvalidateUser(user: User) {
        //TODO: Invalidate cache!
        
        userListeners[user.uid]?.forEach { $0.fn(user) }
    }
    
    func onInvalidateActivity(activity: Activity) {
        //TODO: Invalidate cache!
        
        activityListeners[activity.activityId]?.forEach { $0.fn(activity) }
    }
}
