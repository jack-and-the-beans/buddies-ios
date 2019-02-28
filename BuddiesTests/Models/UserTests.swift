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
            "date_joined" : Timestamp(date: Date())
        ], docId: "my_uid"), with: deli)
        
        otherUser = Buddies.OtherUser.from(snap: MockDocumentSnapshot(data: [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio",
            "date_joined" : Timestamp(date: Date())
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
        XCTAssert(deli.invalidations == 10, "one per line here. no de-dup expected")
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
}
