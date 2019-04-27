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
    var imageVersion: Int { get }
    var dateJoined: Date { get }
    var name: String { get }
    var bio: String { get }
    var favoriteTopics: [String] { get }
    func isEqual(to user: User) -> Bool
}

class OtherUser : User, Equatable {
    let uid: UserId
    var image: UIImage?
    let imageUrl: String
    let imageVersion: Int
    let dateJoined: Date
    let name: String
    let bio: String
    let favoriteTopics: [String]
    
    init(uid: UserId,
         imageUrl: String,
         imageVersion: Int,
         dateJoined: Date,
         name: String,
         bio: String,
         favoriteTopics: [String],
         image: UIImage? = nil) {
        self.uid = uid
        self.imageUrl = imageUrl
        self.imageVersion = imageVersion
        self.dateJoined = dateJoined
        self.name = name
        self.bio = bio
        self.favoriteTopics = favoriteTopics
    }
    
    //create user from a DocumentSnapshot of a user document
    static func from(snap: DocumentSnapshot) -> OtherUser? {
        guard let data = snap.data(),
            let imageUrl = data["image_url"] as? String,
            let name = data["name"] as? String,
            let bio = data["bio"] as? String,
            let dateJoined = data["date_joined"] as? Timestamp
            else { return nil }
        
        let uid = snap.documentID
        let favoriteTopics = data["favorite_topics"] as? [String] ?? []
        let imageVersion = data["image_version"] as? Int ?? 0
        
        return OtherUser(uid: uid,
                         imageUrl: imageUrl,
                         imageVersion: imageVersion,
                         dateJoined: dateJoined.dateValue(),
                         name: name,
                         bio: bio,
                         favoriteTopics: favoriteTopics)
    }

    func isEqual(to user: User) -> Bool {
        return self.uid == user.uid &&
            self.name == user.name &&
            self.bio == user.bio &&
            self.imageVersion == user.imageVersion &&
            self.image == user.image &&
            self.favoriteTopics == user.favoriteTopics
    }

    static func == (lhs: OtherUser, rhs: OtherUser) -> Bool {
        return lhs.isEqual(to: rhs)
    }
    
    func copy() -> OtherUser {
        return OtherUser(uid: uid,
                         imageUrl: imageUrl,
                         imageVersion: imageVersion,
                         dateJoined: dateJoined,
                         name: name,
                         bio: bio,
                         favoriteTopics: favoriteTopics,
                         image: image)
    }
}

class LoggedInUser : User, Equatable {
    
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
    var imageUrl : String { didSet { onChange("image_url", oldValue, imageUrl) } }
    var imageVersion : Int { didSet { onChange("image_version", oldValue, imageVersion) } }
    
    var name : String { didSet { onChange("name", oldValue, name) } }
    var bio : String { didSet { onChange("bio", oldValue, bio) } }
    var favoriteTopics : [String] { didSet { onChange("favorite_topics", oldValue, favoriteTopics) } }
    var location : GeoPoint? { didSet { onChange("location", oldValue, location) } }
    var filterSettings : [String:Int] { didSet { onChange("filter_settings", oldValue, filterSettings) } }
    
    var locationCoords: (Double, Double)? {
        get {
            if let loc = location {
                return (loc.latitude, loc.longitude)
            } else { return nil }
        }
    }
    
    // MARK: User Settings
    var shouldSendJoinedActivityNotification : Bool {
        didSet {
            onChange("should_send_joined_activity_notification", oldValue,
                     shouldSendJoinedActivityNotification)
        }
    }
    var shouldSendActivitySuggestionNotification : Bool {
        didSet {
            onChange("should_send_activity_suggestion_notification", oldValue,
                     shouldSendActivitySuggestionNotification)
        }
    }
    
    // MARK: Blocking
    var blockedUsers : [UserId] { didSet { onChange("blocked_users", oldValue, blockedUsers) } }
    var blockedActivities : [ActivityId] { didSet { onChange("blocked_activities", oldValue, blockedActivities) } }
    let blockedBy : [UserId] // Shouldn't be updated directly! Automatic inverse of blocked_users.
    
    var userBlockList: [UserId] {
        return blockedUsers + blockedBy
    }

    func isBlocked(user: UserId?) -> Bool {
        guard let user = user else { return false }
        // Never block yourself:
        if (user == self.uid) {
            return false
        } else {
            return userBlockList.contains(user)
        }
    }

    func isBlocked(activity: Activity?) -> Bool {
        // Nil should not be blocked (so that changes can propogate correctly):
        guard let activity = activity else { return false }

        // Never block your own activities:
        let ownStatus = activity.getMemberStatus(of: self.uid)
        if ownStatus == .owner {
            return false
        } else if ownStatus == .banned {
            return true
        } else if blockedActivities.contains(activity.activityId) {
            return true
        }

        for id in activity.members {
            if (isBlocked(user: id)) {
                return true
            }
        }
        return false
    }

    func isUserBlockListDifferent(_ newUser: LoggedInUser?) -> Bool {
        if let newUser = newUser {
            let oldList = Set(blockedUsers + blockedBy)
            let newList = Set(newUser.blockedUsers + newUser.blockedBy)
            return oldList != newList
        } else {
            let numBlocked = self.blockedUsers.count + self.blockedBy.count
            return numBlocked > 0
        }
    }
    
    func isActivityBlockListDifferent(_ newUser: LoggedInUser?) -> Bool {
        if let newUser = newUser {
            let oldList = Set(blockedActivities)
            let newList = Set(newUser.blockedActivities)
            return oldList != newList
        } else {
            return self.blockedActivities.count > 0
        }
    }

    // map of activity ID to timestamp - when the user last read the chat.
    var chatReadAt: [ ActivityId: Timestamp ] { didSet { onChange("chat_read_at", oldValue, chatReadAt) } }
    
    private func onChange<T : Equatable>(_ key: String, _ oldValue: T?, _ newValue: T?) {
        if oldValue != newValue {
            delegate?.onInvalidateLoggedInUser(user: self)
            delegate?.triggerServerUpdate(userId: uid, key: key, value: newValue)
        }
    }
    
    init(delegate: LoggedInUserInvalidationDelegate?,
         imageUrl: String,
         imageVersion: Int,
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
         filterSettings: [String:Int],
         notificationToken: String?,
         chatReadAt: [ ActivityId: Timestamp ]) {
        self.delegate = delegate
        self.imageUrl = imageUrl
        self.imageVersion = imageVersion
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
        self.filterSettings = filterSettings
        self.notificationToken = notificationToken
        self.chatReadAt = chatReadAt
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
        let imageVersion = data["image_version"] as? Int ?? 0
        
        let shouldSendJoinedActivityNotification =
            data["should_send_joined_activity_notification"] as? Bool ?? true
        let shouldSendActivitySuggestionNotification =
            data["should_send_activity_suggestion_notification"] as? Bool ?? true
        
        return LoggedInUser(delegate: delegate,
                    imageUrl: imageUrl,
                    imageVersion: imageVersion,
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
                    filterSettings: data["filter_settings"] as? [String:Int] ?? FilterSearchBar.defaultSettings,
                    notificationToken: data["notification_token"] as? String,
                    chatReadAt: chatReadAt)
    }

    func isEqual(to user: User) -> Bool {
        return self.uid == user.uid &&
            self.name == user.name &&
            self.bio == user.bio &&
            self.imageVersion == user.imageVersion &&
            self.image == user.image &&
            self.favoriteTopics == user.favoriteTopics
    }

    static func == (lhs: LoggedInUser, rhs: LoggedInUser) -> Bool {
        return lhs.isEqual(to: rhs) &&
            lhs.email == rhs.email &&
            lhs.facebookId == rhs.facebookId &&
            lhs.favoriteTopics == rhs.favoriteTopics &&
            lhs.isAdmin == rhs.isAdmin &&
            lhs.blockedUsers == rhs.blockedUsers &&
            lhs.blockedBy == rhs.blockedBy &&
            lhs.blockedActivities == rhs.blockedActivities &&
            lhs.location == rhs.location &&
            lhs.shouldSendJoinedActivityNotification == rhs.shouldSendJoinedActivityNotification &&
            lhs.shouldSendActivitySuggestionNotification == rhs.shouldSendActivitySuggestionNotification &&
            lhs.filterSettings == rhs.filterSettings &&
            lhs.notificationToken == rhs.notificationToken
    }
}
