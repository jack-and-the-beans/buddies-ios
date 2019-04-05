//
//  Activity.swift
//  Buddies
//
//  Created by Jake Thurman on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

typealias ActivityId = String

protocol ActivityInvalidationDelegate {
    func onInvalidateActivity(activity: Activity?, id: String)
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?)
}

enum MemberStatus {
    case owner
    case member
    case banned
    case none
}

class Activity: Equatable {
    let delegate: ActivityInvalidationDelegate?
    
    // MARK: Immutable properties
    let activityId : ActivityId
    let dateCreated : Timestamp
    
    var timeRange: DateInterval {
        get {
            return DateInterval(start: self.startTime.dateValue(), end: self.endTime.dateValue())
        }
    }

    // MARK: Mutable properties
    var members : [UserId] { didSet { onChange("members", oldValue, members) } }
    var location : GeoPoint { didSet { onChange("location", oldValue, location) } }
    var ownerId : UserId { didSet { onChange("owner_id", oldValue, ownerId) } }
    var title : String { didSet { onChange("title", oldValue, title) } }
    var description : String { didSet { onChange("description", oldValue, description) } }
    var startTime : Timestamp { didSet { onChange("start_time", oldValue, startTime) } }
    var endTime : Timestamp { didSet { onChange("end_time", oldValue, endTime) } }
    var topicIds : [String] { didSet { onChange("topic_ids", oldValue, topicIds) } }
    var bannedUsers : [UserId] { didSet { onChange("banned_users", oldValue, bannedUsers) } }
    var locationText : String { didSet { onChange("location_text", oldValue, locationText) } }
    var users = [User]()

    private func onChange<T : Equatable>(_ key: String, _ oldValue: T?, _ newValue: T?) {
        if oldValue != newValue {
            delegate?.onInvalidateActivity(activity: self, id: activityId)
            delegate?.triggerServerUpdate(activityId: activityId, key: key, value: newValue)
        }
    }
    
    init(delegate: ActivityInvalidationDelegate?,
         activityId: ActivityId,
         dateCreated: Timestamp,
         members: [UserId],
         location: GeoPoint,
         ownerId: UserId,
         title: String,
         description: String,
         startTime: Timestamp,
         endTime: Timestamp,
         locationText: String,
         bannedUsers: [UserId],
         topicIds: [String]) {
        self.delegate = delegate
        self.activityId = activityId
        self.dateCreated = dateCreated
        self.members = members
        self.location = location
        self.ownerId = ownerId
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.topicIds = topicIds
        self.locationText = locationText
        self.bannedUsers = bannedUsers
    }
    
    static func from(snap: DocumentSnapshot, with delegate: ActivityInvalidationDelegate?) -> Activity? {
        guard let data = snap.data(),
            let members = data["members"] as? [UserId],
            let location = data["location"] as? GeoPoint,
            let dateCreated = data["date_created"] as? Timestamp,
            let ownerId = data["owner_id"] as? UserId,
            let title = data["title"] as? String,
            let startTime = data["start_time"] as? Timestamp,
            let endTime = data["end_time"] as? Timestamp,
            let topicIds = data["topic_ids"] as? [String]
        else { return nil }
        
        let activityId = snap.documentID
        let description = data["description"] as? String ?? ""
        let locationText = data["location_text"] as? String ?? "🌍"
        let bannedUsers = data["banned_users"] as? [UserId] ?? []

        return Activity(delegate: delegate,
                        activityId: activityId,
                        dateCreated: dateCreated,
                        members: members,
                        location: location,
                        ownerId: ownerId,
                        title: title,
                        description: description,
                        startTime: startTime,
                        endTime: endTime,
                        locationText: locationText,
                        bannedUsers: bannedUsers,
                        topicIds: topicIds)
    }

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return
            lhs.activityId == rhs.activityId &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.members == rhs.members &&
            lhs.topicIds == rhs.topicIds &&
            lhs.location == rhs.location &&
            lhs.locationText == rhs.locationText &&
            lhs.startTime == rhs.startTime &&
            lhs.endTime == rhs.endTime &&
            lhs.bannedUsers == rhs.bannedUsers &&
            lhs.areUsersEqual(to: rhs.users)
    }
    
    func areUsersEqual(to otherUsers: [User]) -> Bool {
        for user in users {
            // See if the user exists anywhere in the other array. We only
            guard let _ = otherUsers.firstIndex(where: { $0.isEqual(to: user) }) else {
                return false
            }
        }
        return true
    }

    func getMemberStatus(of userId: UserId) -> MemberStatus {
        if (self.bannedUsers.contains(userId)) {
            return MemberStatus.banned
        } else if (userId == self.ownerId) {
            return MemberStatus.owner
        } else if (self.members.contains(userId)) {
            return MemberStatus.member
        } else {
            return MemberStatus.none
        }
    }
    
    func removeMember(with uid: UserId) {
        if let i = self.members.index(of: uid) {
            self.members.remove(at: i)
        }
    }
    
    func addMember(with uid: UserId) {
        if (getMemberStatus(of: uid) == .none) {
            self.members.append(uid)
        }
    }
    
    func banUser(with uid: UserId) {
        if (members.contains(uid)) {
            removeMember(with: uid)
        }
        if (!bannedUsers.contains(uid)) {
            bannedUsers.append(uid)
        }
    }
}
