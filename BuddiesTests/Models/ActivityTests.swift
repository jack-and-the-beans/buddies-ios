//
//  ActivityTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
import FirebaseFirestore
@testable import Buddies

class ActivityTests: XCTestCase {
    let testDate = Date()
    let testDate2 = Date()
    func createActivity(id: String) -> Activity {
        return Activity.init(delegate: deli,
                              activityId: id,
                              dateCreated: Timestamp(date: Date()),
                              members: [],
                              location: GeoPoint(latitude: 0, longitude: 0),
                              ownerId: "ownerId",
                              title: "title",
                              description: "description",
                              startTime: Timestamp(date: testDate),
                              endTime: Timestamp(date: testDate2),
                              locationText: "What up buddy",
                              bannedUsers: [],
                              topicIds: [])
    }
    func createUser(id: String) -> OtherUser {
        return OtherUser.init(uid: id, imageUrl: "yummy", imageVersion: 0, dateJoined: testDate, name: "hi", bio: "hi", favoriteTopics: [])
    }

    class TestDeli : ActivityInvalidationDelegate {
        var invalidations = 0
        var triggers = 0
        func onInvalidateActivity(activity: Activity?, id: String) {
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
        activity.startTime = Timestamp(date: Date().addingTimeInterval(TimeInterval(50)))
        activity.endTime = Timestamp(date: Date().addingTimeInterval(TimeInterval(10)))
        
        activity.topicIds = ["x", "y"]
        activity.topicIds = ["x", "y"] // The same on purpose!
        
        XCTAssert(deli.invalidations == deli.triggers, "should call both")
        XCTAssert(deli.invalidations == 7, "Called once per CHANGE (not repeats)")
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
                              bannedUsers: [],
                              topicIds: [])
        
        XCTAssert(a.activityId == "activityId")
        XCTAssert(a.title == "title")
        XCTAssert(a.ownerId == "ownerId")
        XCTAssert(a.description == "description")
    }

    func testTimeRagne() {
        let x = activity.timeRange
        XCTAssertLessThan(x.duration, 1) // Because it'd be foolish to do an equality comparision on a double
    }

    func testEquality() {
        let a = createActivity(id: "abc")
        let b = createActivity(id: "abc")
        XCTAssertTrue(a == b)
        let c = createActivity(id: "1")
        XCTAssertFalse(a == c)
    }
    
    func testAreUsersEqual() {
        let a = createActivity(id: "abcde")
        let user1 = createUser(id: "hello")
        let users = [ user1 ]
        XCTAssertFalse(a.areUsersEqual(to: users))
        
        let user2 = createUser(id: "hello")
        a.users = [ user2 ]
        XCTAssertTrue(a.areUsersEqual(to: users))
        
        let user3 = createUser(id: "hello2")
        a.users = [ user3 ]
        XCTAssertFalse(a.areUsersEqual(to: users))
    }
    
    func testGetMemberStatus() {
        let a = createActivity(id: "howdy")
        a.bannedUsers = ["a"]
        
        XCTAssertTrue(a.getMemberStatus(of: "a") == .banned)
        
        let b = createActivity(id: "howdy2")
        b.ownerId = "a"
        XCTAssertTrue(b.getMemberStatus(of: "a") == .owner)

        let c = createActivity(id: "howdy2")
        c.members = ["c"]
        XCTAssertTrue(c.getMemberStatus(of: "c") == .member)

        let d = createActivity(id: "howdy2")
        XCTAssertTrue(d.getMemberStatus(of: "c") == .none)
    }
    
    func testRemoveMember() {
        let a = createActivity(id: "howdy")
        a.removeMember(with: "notme")
        XCTAssertTrue(a.members == [])

        let b = createActivity(id: "howdy")
        b.members = ["notme"]
        XCTAssertTrue(b.members.contains("notme"))
        b.removeMember(with: "notme")
        XCTAssertFalse(b.members.contains("notme"))
    }
    
    func testRemoveMember2() {
        let b = createActivity(id: "howdy")
        b.members = ["me", "notme"]
        XCTAssertTrue(b.members.contains("notme"))
        b.removeMember(with: "notme")
        XCTAssertFalse(b.members.contains("notme"))
    }

    func testAddMember() {
        let b = createActivity(id: "howdy")
        b.members = ["me", "notme"]
        XCTAssertTrue(b.members.contains("notme"))
        b.addMember(with: "notme")
        XCTAssertTrue(b.members == ["me", "notme"])
    }
    
    func testAddMember2() {
        let b = createActivity(id: "howdy")
        b.members = ["me"]
        b.bannedUsers = ["notme"]
        b.addMember(with: "notme")
        XCTAssertFalse(b.members.contains("notme"))
    }

    func testAddMember3() {
        let b = createActivity(id: "howdy")
        b.members = []
        b.addMember(with: "notme")
        XCTAssertTrue(b.members.contains("notme"))
    }

    func testBanUser() {
        let a = createActivity(id: "hello")
        a.members = [ "a" ]
        a.banUser(with: "a")
        XCTAssertFalse(a.members.contains("a"))
        XCTAssertTrue(a.bannedUsers.contains("a"))
        
        a.banUser(with: "a")
        XCTAssertFalse(a.members.contains("a"))
        XCTAssertTrue(a.bannedUsers.contains("a"))
    }
}
