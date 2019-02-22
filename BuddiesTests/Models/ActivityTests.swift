//
//  ActivityTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
@testable import Buddies

class ActivityTests: XCTestCase {
    class TestDeli : ActivityInvalidationDelegate {
        var invalidations = 0
        var triggers = 0
        func onInvalidateActivity(activity: Activity) {
            invalidations += 1
        }
        
        func triggerServerUpdate(activityId: ActivityId, key: String, value: Any?) {
            triggers += 1
        }
    }
    
    var deli: TestDeli!
    var activity: Activity!
    
    override func setUp() {
        deli = TestDeli()
        
        activity = Activity.from(snap: MockDocumentSnapshot(data: [
            "members": [],
            "location": GeoPoint(latitude: 10.0, longitude: 10.0),
            "date_created": Timestamp(date: Date()),
            "owner_id": "bob_id",
            "title": "My Event",
            "topic_ids": [],
            "start_time": Timestamp(date: Date()),
            "end_time": Timestamp(date: Date()),
        ], docId: "my-activity-id"), with: deli)
    }
    
    func testMutations() {
        activity.members = ["bob_id", "joe_id", "sam_id"]
        activity.location = GeoPoint(latitude: -10.0, longitude: 5.0)
        activity.ownerId = "bob_id" // The same on purpose!
        activity.title = "Hello, I'm an event!"
        activity.description = "a new desc"
        activity.startTime = Timestamp(date: Date().addingTimeInterval(TimeInterval(-50)))
        activity.endTime = Timestamp(date: Date().addingTimeInterval(TimeInterval(-10)))
        
        activity.topicIds = []
        activity.topicIds = ["x", "y"] // Indecisive!
        
        XCTAssert(deli.invalidations == deli.triggers, "should call both")
        XCTAssert(deli.invalidations == 9, "one per line here. no de-dup expected")
    }
    
    func testInit(){
        let a = Activity.init(delegate: deli,
                              activityId: "activityId",
                              dateCreated: Timestamp(date: Date()),
                              members: [],
                              location: GeoPoint(latitude: 0, longitude: 0),
                              ownerId: "ownerId",
                              title: "title",
                              description: "description",
                              startTime: Timestamp(date: Date()),
                              endTime: Timestamp(date: Date()),
                              locationText: "What up buddy",
                              topicIds: [])
        
        XCTAssert(a.activityId == "activityId")
        XCTAssert(a.title == "title")
        XCTAssert(a.ownerId == "ownerId")
        XCTAssert(a.description == "description")
    }
}
