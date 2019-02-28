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

protocol LoggedInUserInvalidationDelegate {
    func onInvalidateLoggedInUser(user: LoggedInUser?)
    func triggerServerUpdate(userId: UserId, key: String, value: Any?)
}

protocol User {
    var uid: UserId { get }
    var image: UIImage? { get set }
    var imageUrl: String { get }
    var dateJoined: Date { get }
    var name: String { get }
    var bio: String { get }
    var favoriteTopics: [String] { get }
}

class OtherUser : User {
    let uid: UserId
    var image: UIImage?
    let imageUrl: String
    let dateJoined: Date
    let name: String
    let bio: String
    let favoriteTopics: [String]
    
    init(uid: UserId,
         imageUrl: String,
         dateJoined: Date,
         name: String,
         bio: String,
         favoriteTopics: [String]) {
        self.uid = uid
        self.imageUrl = imageUrl
        self.dateJoined = dateJoined
        self.name = name
        self.bio = bio
        self.favoriteTopics = favoriteTopics
    }
    
    static func from(snap: DocumentSnapshot) -> OtherUser? {
        guard let data = snap.data(),
            let imageUrl = data["image_url"] as? String,
            let name = data["name"] as? String,
            let bio = data["bio"] as? String,
            let dateJoined = data["date_joined"] as? Timestamp
            else { return nil }
        
        let uid = snap.documentID
        let favoriteTopics = data["favorite_topics"] as? [String] ?? []
        
        return OtherUser(uid: uid,
                         imageUrl: imageUrl,
                         dateJoined: dateJoined.dateValue(),
                         name: name,
                         bio: bio,
                         favoriteTopics: favoriteTopics)
    }
}

class LoggedInUser : User {
    
    let delegate: LoggedInUserInvalidationDelegate?
    
    var image : UIImage? { didSet { delegate?.onInvalidateLoggedInUser(user: self) } }

    // MARK: Immutable Properties
    let uid : UserId
    let email : String?
    let isAdmin : Bool
    let facebookId : String?
    let dateJoined : Date
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
        delegate?.onInvalidateLoggedInUser(user: self)
        delegate?.triggerServerUpdate(userId: uid, key: key, value: value)
    }
    
    init(delegate: LoggedInUserInvalidationDelegate?,
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
         dateJoined: Date,
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
    
    // For testing... (ew)
    init(name: String) {
        self.delegate = nil
        self.imageUrl = ""
        self.isAdmin = false
        self.uid = name
        self.name = name
        self.bio = name
        self.email = name
        self.facebookId = name
        self.favoriteTopics = []
        self.blockedUsers = []
        self.blockedBy = []
        self.blockedActivities = []
        self.dateJoined = Date()
        self.location = nil
        self.shouldSendJoinedActivityNotification = false
        self.shouldSendActivitySuggestionNotification = false
        self.notificationToken = name
        self.chatReadAt = ["no":Timestamp()]
    }
    
    static func from(snap: DocumentSnapshot, with delegate: LoggedInUserInvalidationDelegate?) -> LoggedInUser? {
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
        
        return LoggedInUser(delegate: delegate,
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
                    dateJoined: dateJoined.dateValue(),
                    location: data["location"] as? GeoPoint,
                    shouldSendJoinedActivityNotification: shouldSendJoinedActivityNotification,
                    shouldSendActivitySuggestionNotification: shouldSendActivitySuggestionNotification,
                    notificationToken: data["notification_token"] as? String,
                    chatReadAt: chatReadAt)
    }
}
