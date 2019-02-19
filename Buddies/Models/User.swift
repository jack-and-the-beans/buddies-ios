//
//  User.swift
//  Buddies
//
//  Created by Jake Thurman on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

typealias UserId = String

protocol UserInvalidationDelegate {
    func onInvalidateUser(user: User)
    func triggerServerUpdate(userId: UserId, key: String, value: Any?)
}

class User {
    let delegate: UserInvalidationDelegate?
    
    // MARK: Immutable Properties
    let uid : UserId
    let email : String?
    let isAdmin : Bool
    let facebookId : String?
    let dateJoined : Timestamp
    let notificationToken : String?
    
    // MARK: Mutable Properties
    var imageUrl : String { didSet { onChange("image_url", imageUrl) } }
    var name : String { didSet { onChange("name", name) } }
    var bio : String { didSet { onChange("bio", bio) } }
    var favoriteTopics : [String] { didSet { onChange("favorite_topics", favoriteTopics) } }
    var location : GeoPoint? { didSet { onChange("location", location) } }
    
    // MARK: User Settings
    var shouldSendJoinedActivityNotification : Bool {
        didSet {
            onChange("should_send_joined_activity_notification",
                     shouldSendJoinedActivityNotification)
        }
    }
    var shouldSendActivitySuggestionNotification : Bool {
        didSet {
            onChange("should_send_activity_suggestion_notification",
                     shouldSendActivitySuggestionNotification)
        }
    }
    
    // MARK: Blocking
    var blockedUsers : [UserId] { didSet { onChange("blocked_users", blockedUsers) } }
    var blockedActivities : [ActivityId] { didSet { onChange("blocked_activities", blockedActivities) } }
    let blockedBy : [UserId] // Shouldn't be updated directly! Automatic inverse of blocked_users.
    
    // map of activity ID to timestamp - when the user last read the chat.
    var chatReadAt: [ ActivityId: Timestamp ] { didSet { onChange("chat_read_at", chatReadAt) } }
    
    private func onChange(_ key: String, _ value: Any?) {
        delegate?.onInvalidateUser(user: self)
        delegate?.triggerServerUpdate(userId: uid, key: key, value: value)
    }
    
    init(delegate: UserInvalidationDelegate?,
         imageUrl: String,
         isAdmin: Bool,
         uid: String,
         name: String,
         bio: String, email: String?,
         facebookId: String?,
         favoriteTopics: [String],
         blockedUsers: [UserId],
         blockedBy: [UserId],
         blockedActivities: [ActivityId],
         dateJoined: Timestamp,
         location: GeoPoint?,
         shouldSendJoinedActivityNotification: Bool,
         shouldSendActivitySuggestionNotification: Bool,
         notificationToken: String?,
         chatReadAt: [ ActivityId: Timestamp ]) {
        self.delegate = delegate
        self.imageUrl = imageUrl
        self.isAdmin = isAdmin
        self.uid = uid
        self.name = name
        self.bio = bio
        self.email = email
        self.facebookId = facebookId
        self.favoriteTopics = favoriteTopics
        self.blockedUsers = blockedUsers
        self.blockedBy = blockedBy
        self.blockedActivities = blockedActivities
        self.dateJoined = dateJoined
        self.location = location
        self.shouldSendJoinedActivityNotification = shouldSendJoinedActivityNotification
        self.shouldSendActivitySuggestionNotification = shouldSendActivitySuggestionNotification
        self.notificationToken = notificationToken
        self.chatReadAt = chatReadAt
    }
    
    static func from(snap: DocumentSnapshot, with delegate: UserInvalidationDelegate?) -> User? {
        guard let data = snap.data(),
              let imageUrl = data["image_url"] as? String,
              let name = data["name"] as? String,
              let bio = data["bio"] as? String,
              let dateJoined = data["date_joined"] as? Timestamp
        else { return nil }
        
        let uid = snap.documentID
        let isAdmin = data["is_admin"] as? Bool ?? false
        let email = data["email"] as? String
        let facebookId = data["facebook_access_token"] as? String
        let favoriteTopics = data["favorite_topics"] as? [String] ?? []
        let blockedUsers = data["blocked_users"] as? [String] ?? []
        let blockedBy = data["blocked_by"] as? [String] ?? []
        let blockedActivities = data["blocked_activities"] as? [String] ?? []
        let chatReadAt = data["chat_read_at"] as? [String:Timestamp] ?? [:]
        
        let shouldSendJoinedActivityNotification =
            data["should_send_joined_activity_notification"] as? Bool ?? true
        let shouldSendActivitySuggestionNotification =
            data["should_send_activity_suggestion_notification"] as? Bool ?? true
        
        return User(delegate: delegate,
                    imageUrl: imageUrl,
                    isAdmin: isAdmin,
                    uid: uid,
                    name: name,
                    bio: bio,
                    email: email,
                    facebookId: facebookId,
                    favoriteTopics: favoriteTopics,
                    blockedUsers: blockedUsers,
                    blockedBy: blockedBy,
                    blockedActivities: blockedActivities,
                    dateJoined: dateJoined,
                    location: data["location"] as? GeoPoint,
                    shouldSendJoinedActivityNotification: shouldSendJoinedActivityNotification,
                    shouldSendActivitySuggestionNotification: shouldSendActivitySuggestionNotification,
                    notificationToken: data["notification_token"] as? String,
                    chatReadAt: chatReadAt)
    }
}
