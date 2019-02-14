//
//  UserTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
@testable import Buddies

class UserTests: XCTestCase {
    class TestDeli : UserInvalidationDelegate {
        var invalidations = 0
        var triggers = 0
        func onInvalidateUser(user: Buddies.User) {
            invalidations += 1
        }
        
        func triggerServerUpdate(userId: UserId, key: String, value: Any?) {
            triggers += 1
        }
    }
    
    var deli: TestDeli!
    var user: Buddies.User!
    
    override func setUp() {
        deli = TestDeli()
        
        user = Buddies.User.from(snap: MockDocumentSnapshot(data: [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio\nDo you like it?",
            "email" : "fake@example.com",
            "date_joined" : Timestamp(date: Date())
        ], docId: "my_uid"), with: deli)
    }
    
    func testMutations() {
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
}
