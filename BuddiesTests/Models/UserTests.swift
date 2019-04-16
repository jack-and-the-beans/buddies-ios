//
//  UserTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
import FirebaseFirestore

@testable import Buddies

class UserTests: XCTestCase {
    let testDate = Date()
    func createActivity(id: String) -> Activity {
        return Activity.init(delegate: nil,
                             activityId: id,
                             dateCreated: Timestamp(date: Date()),
                             members: [],
                             location: GeoPoint(latitude: 0, longitude: 0),
                             ownerId: "ownerId",
                             title: "title",
                             description: "description",
                             startTime: Timestamp(date: testDate),
                             endTime: Timestamp(date: testDate),
                             locationText: "What up buddy",
                             bannedUsers: [],
                             topicIds: [])
    }
    func createOtherUser(id: String) -> OtherUser {
        return OtherUser.init(uid: id, imageUrl: "image_url", imageVersion: 0, dateJoined: testDate, name: "Test User", bio: "This is my bio", favoriteTopics: [])
    }
    func createLoggedInUser(id: String) -> LoggedInUser {
        return LoggedInUser.init(delegate: nil, imageUrl: "howdy", imageVersion: 0, isAdmin: false, uid: id, name: "my name is bob", bio: "not bob", email: "bob", facebookId: nil, favoriteTopics: ["a"], blockedUsers: [], blockedBy: [], blockedActivities: [], dateJoined: testDate, location: nil, shouldSendJoinedActivityNotification: false, shouldSendActivitySuggestionNotification: false, filterSettings: [:], notificationToken: nil, chatReadAt: [:])
    }

    class TestDeli : LoggedInUserInvalidationDelegate {
        var invalidations = 0
        var triggers = 0
        func onInvalidateLoggedInUser(user: Buddies.LoggedInUser?) {
            invalidations += 1
        }
        
        func triggerServerUpdate(userId: UserId, key: String, value: Any?) {
            triggers += 1
        }
    }
    
    var deli: TestDeli!
    var user: Buddies.LoggedInUser!
    var otherUser: Buddies.OtherUser!
    
    override func setUp() {
        deli = TestDeli()
        
        user = Buddies.LoggedInUser.from(snap: MockDocumentSnapshot(data: [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio\nDo you like it?",
            "email" : "fake@example.com",
            "date_joined" : Timestamp(date: testDate)
        ], docId: "my_uid"), with: deli)
        
        otherUser = Buddies.OtherUser.from(snap: MockDocumentSnapshot(data: [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio",
            "date_joined" : Timestamp(date: testDate)
        ], docId: "their_uid"))
    }
    
    func testLoggdInUserMutations() {
        user.imageUrl = "blah.com"
        user.name = "jared"
        user.bio = "This is my bio\nDo you like it?" //The same as before, expected to recall
        user.favoriteTopics = ["x", "y", "z"]
        user.location = nil
        user.shouldSendJoinedActivityNotification = true
        
        user.shouldSendActivitySuggestionNotification = false
        user.shouldSendActivitySuggestionNotification = true // indecisive
        
        user.blockedUsers = []
        user.blockedActivities = ["a", "b", "c"]
        
        XCTAssert(deli.invalidations == deli.triggers, "should call both")
        XCTAssert(deli.invalidations == 6, "two per change. no de-dup expected")
    }
    
    func testLoggedInUserInit(){
        XCTAssert(user.imageUrl == "image_url")
        XCTAssert(user.isAdmin == false)
        XCTAssert(user.uid == "my_uid")
        XCTAssert(user.email == "fake@example.com")
        XCTAssert(user.name == "Test User")
    }
    
    func testOtherUserInit(){
        XCTAssert(otherUser.imageUrl == "image_url")
        XCTAssert(otherUser.name == "Test User")
        XCTAssert(otherUser.uid == "their_uid")
        XCTAssert(otherUser.bio == "This is my bio")
    }
    
    func testOtherUserEquality() {
        let user1 = createOtherUser(id: "hi fam")
        XCTAssertFalse(user1.isEqual(to: user))
        
        let user2 = createOtherUser(id: "my_uid")
        let user3 = createOtherUser(id: "my_uid")
        XCTAssertTrue(user2.isEqual(to: user3))
        
        XCTAssertTrue(user2 == user3)
    }
    
    func testCurUserEquality() {
        let user1 = createLoggedInUser(id: "hi fam")
        XCTAssertFalse(user1.isEqual(to: user))
        
        let user2 = createLoggedInUser(id: "my_uid")
        let user3 = createLoggedInUser(id: "my_uid")
        XCTAssertTrue(user2.isEqual(to: user3))
        
        XCTAssertTrue(user2 == user3)
    }

    func testIsBlocked() {
        let user1 = createLoggedInUser(id: "me")
        user1.blockedUsers = ["me", "not_me"]
        XCTAssertFalse(user1.isBlocked(user: "me"))
        XCTAssertTrue(user1.isBlocked(user: "not_me"))
    }

    func testIsBlocked1() {
        let user1 = createLoggedInUser(id: "me")
        XCTAssertFalse(user1.isBlocked(user: nil))
    }

    func testIsActivityBlocked() {
        let user1 = createLoggedInUser(id: "me")
        XCTAssertFalse(user1.isBlocked(activity: nil))
    }
    
    func testIsActivityBlocked2() {
        let user1 = createLoggedInUser(id: "me")
        let activity = createActivity(id: "this activity tho")
        activity.bannedUsers = [ "me" ]
        XCTAssertTrue(user1.isBlocked(activity: activity))
    }
    
    func testIsActivityBlocked3() {
        let user1 = createLoggedInUser(id: "me")
        user1.blockedActivities = [ "meme big boy" ]
        let activity = createActivity(id: "meme big boy")
        XCTAssertTrue(user1.isBlocked(activity: activity))
    }
    
    func testIsActivityBlocked4() {
        let user1 = createLoggedInUser(id: "me")
        user1.blockedUsers = [ "not me" ]
        let activity = createActivity(id: "meme big boy")
        activity.members = [ "not me" ]
        XCTAssertTrue(user1.isBlocked(activity: activity))
    }
    
    func testIsActivityBlocked5() {
        let user1 = createLoggedInUser(id: "me")
        let activity = createActivity(id: "meme big boy")
        XCTAssertFalse(user1.isBlocked(activity: activity))
    }
    
    func testUserBlockListDiff() {
        let user1 = createLoggedInUser(id: "me")
        let user2 = createLoggedInUser(id: "them")
        user2.blockedUsers = ["hi"]
        XCTAssertTrue(user1.isUserBlockListDifferent(user2))
    }

    func testUserBlockListDiff2() {
        let user1 = createLoggedInUser(id: "me")
        XCTAssertFalse(user1.isUserBlockListDifferent(nil))
    }
    
    func testActivityBlockListDiff() {
        let user1 = createLoggedInUser(id: "me")
        let user2 = createLoggedInUser(id: "them")
        user2.blockedActivities = ["hi"]
        XCTAssertTrue(user1.isActivityBlockListDifferent(user2))
    }
    
    func testActivityBlockListDiff2() {
        let user1 = createLoggedInUser(id: "me")
        XCTAssertFalse(user1.isActivityBlockListDifferent(nil))
    }
}
