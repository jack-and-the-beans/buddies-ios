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
    func onInvalidateActivity(activity: Activity)
    func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?)
}

enum MemberStatus {
    case owner
    case member
    case none
}

class Activity {
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
    var members : [UserId] { didSet { onChange("members", members) } }
    var location : GeoPoint { didSet { onChange("location", location) } }
    var ownerId : UserId { didSet { onChange("owner_id", ownerId) } }
    var title : String { didSet { onChange("title", title) } }
    var description : String { didSet { onChange("description", description) } }
    var startTime : Timestamp { didSet { onChange("start_time", startTime) } }
    var endTime : Timestamp { didSet { onChange("end_time", endTime) } }
    var topicIds : [String] { didSet { onChange("topic_ids", topicIds) } }
    
    private func onChange(_ key: String, _ value: Any?) {
        delegate?.onInvalidateActivity(activity: self)
        delegate?.triggerServerUpdate(activityId: activityId, key: key, value: value)
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
                        topicIds: topicIds)
    }

    func getMemberStatus(of userId: String) -> MemberStatus {
        if (userId == self.ownerId) {
            return MemberStatus.owner
        } else if (self.members.contains(userId)) {
            return MemberStatus.member
        } else {
            return MemberStatus.none
        }
    }
}
