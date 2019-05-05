//
//  DataAccessorTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
import FirebaseFirestore
@testable import Buddies

class MockUser : Firebase.User {
    override var uid: String { get { return "my_uid" } }
    init(_ workaround: Any) {}
}

class DataAccessorTests: XCTestCase {
    var cancels: [Canceler] = []
    var instance: DataAccessor!
    var me: Buddies.LoggedInUser!
    var them: Buddies.OtherUser!
    var myActivity: Activity!

    override func setUp() {
        // Create user stuff
        let user = MockUser(0)
        let usersCollection = MockCollectionReference()
        let meDoc = MockDocumentReference(docId: user.uid)
        meDoc.exposedData = [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio\nDo you like it?",
            "email" : "fake@example.com",
            "date_joined" : Timestamp(date: Date())
        ]
        usersCollection.documents[user.uid] = meDoc
        
        let theirUID = "some_other_dude"
        let themDoc = MockDocumentReference(docId: theirUID)
        themDoc.exposedData = [
            "image_url" : "another_image_url",
            "name" : "Fake Friend",
            "bio" : "This is their bio",
            "email" : "another@example.com",
            "date_joined" : Timestamp(date: Date())
        ]
        usersCollection.documents[theirUID] = themDoc
        
        
        // Create activity stuff
        let activityId = "my_activity"
        let activitiesCollection = MockCollectionReference()
        let activityDoc = MockDocumentReference(docId: activityId)
        activityDoc.exposedData = [
            "members": [],
            "location": GeoPoint(latitude: 10.0, longitude: 10.0),
            "date_created": Timestamp(date: Date()),
            "owner_id": user.uid,
            "title": "My Event",
            "topic_ids": [],
            "start_time": Timestamp(date: Date()),
            "end_time": Timestamp(date: Date()),
        ]
        activitiesCollection.documents[activityId] = activityDoc
        
        // Create the instance to test
        instance = DataAccessor(
            usersCollection: usersCollection,
            accountCollection: usersCollection,
            activitiesCollection: activitiesCollection,
            storageManager: MockStorageManager(),
            addChangeListener: { listener in
                listener(Auth.auth(), user)
                return NSObject()
            },
            removeChangeListener: { handle in /*do nothing*/ })
        
        // Create User object manually, no caching!
        let userSnap = MockDocumentSnapshot(data: meDoc.exposedData, docId: user.uid)
        self.me = Buddies.LoggedInUser.from(snap: userSnap, with: instance)
        
        let themSnap = MockDocumentSnapshot(data: themDoc.exposedData, docId: theirUID)
        self.them = Buddies.OtherUser.from(snap: themSnap)
        
        // Create activity object, no caching!
        let activitySnap = MockDocumentSnapshot(data: activityDoc.exposedData, docId: activityId)
        self.myActivity = Activity.from(snap: activitySnap, with: instance)
        
    }
    
    override func tearDown() {
        cancels.forEach { cancel in cancel() }
        cancels = []
    }
    
    func testUseUser() {
        let exp1 = self.expectation(description: "user loaded")
        exp1.expectedFulfillmentCount = 2
        
        // call
        let cancel1 = instance.useUser(id: them.uid) { user in
            guard let user = user else { return }
            // Check some props were loaded
            XCTAssertEqual(user.uid, self.them.uid)
            XCTAssertEqual(user.name, self.them.name)
            XCTAssertEqual(user.imageUrl, self.them.imageUrl)
            
            exp1.fulfill()
        }
        
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
    }
    
    func testUseLoggedInUser() {
        let exp1 = self.expectation(description: "user loaded")
        
        // call
        let cancel1 = instance.useLoggedInUser { user in
            // Check some props were loaded
            XCTAssertEqual(user?.uid, self.me.uid)
            XCTAssertEqual(user?.imageUrl, self.me.imageUrl)
            XCTAssertEqual(user?.shouldSendActivitySuggestionNotification, self.me.shouldSendActivitySuggestionNotification)
            
            exp1.fulfill()
        }
        
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
    }
    
    func testUseUserWithCache() {
        // first call
        let exp1 = self.expectation(description: "user loaded")
        var calls1 = 0
        let cancel1 = instance.useUser(id: them.uid) { user in
            if calls1 == 0 { exp1.fulfill() }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
        
        // repeat
        let exp2 = self.expectation(description: "user loaded second time")
        var calls2 = 0
        let cancel2 = instance.useUser(id: them.uid) { user in
            if calls2 == 0 { exp2.fulfill() }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 >= 2, "expected first callback to be called at least twice")
        XCTAssert(calls2 < calls1, "expected second callback to be called less")
    }
    
    func testUseUserAfterCancel() {
        // first call
        let exp1 = self.expectation(description: "user loaded")
        var calls1 = 0
        var firstUser: Buddies.OtherUser?
        let cancel1 = instance.useUser(id: them.uid) { user in
            firstUser = user as? OtherUser
            if calls1 == 0 { exp1.fulfill() }
            calls1 += 1
        }
        
        self.waitForExpectations(timeout: 2.0)
        
        // Manually call cancel function
        cancel1()
        
        // repeat
        let exp2 = self.expectation(description: "user loaded second time")
        var calls2 = 0
        let cancel2 = instance.useUser(id: them.uid) { user in
            guard let user = user as? OtherUser else { return }
            if calls2 == 0 {
                XCTAssert(user === firstUser)
            }
            else if calls2 == 1 {
                exp2.fulfill()
            }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        // invalidate, to call again
        instance.onInvalidateUser(user: them)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls2 >= 2, "expected second callback to be called at least twice")
    }
    
    func testOnInvalidateUser() {
        let exp1 = self.expectation(description: "user loaded")
        let exp2 = self.expectation(description: "user loaded second time")
        
        // call
        var calls1 = 0
        let cancel1 = instance.useUser(id: them.uid) { user in
            if calls1 == 0 { exp1.fulfill() }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        // repeat
        var calls2 = 0
        let cancel2 = instance.useUser(id: them.uid) { user in
            if calls2 == 0 { exp2.fulfill() }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        // invalidate, to call again
        instance.onInvalidateUser(user: them)
        
        XCTAssert(calls1 >= 2, "expected first callback to be called twice")
        XCTAssert(calls2 >= 2, "expected second callback to be called at least twice")
    }
    
    func testUseActivity() {
        let exp1 = self.expectation(description: "activity loaded")
        
        // call
        var calls1 = 0
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
            guard let activity = activity else { return }
            // Check some props were loaded
            XCTAssert(activity.activityId == self.myActivity.activityId)
            XCTAssert(activity.ownerId == self.myActivity.ownerId)
            XCTAssert(activity.title == self.myActivity.title)
            
            exp1.fulfill()
            calls1 += 1
        }
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected callback to be called once")
    }
    
    func testUseActivityAfterCancel() {
        // first call
        let exp1 = self.expectation(description: "activity loaded")
        var calls1 = 0
        var firstActivity: Activity?
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
            firstActivity = activity
            exp1.fulfill()
            calls1 += 1
        }
        
        self.waitForExpectations(timeout: 2.0)
        
        // manually cancel first useActivity call
        cancel1()
        
        // repeat
        let exp2 = self.expectation(description: "activity loaded second time")
        var calls2 = 0
        let cancel2 = instance.useActivity(id: myActivity.activityId) { activity in
            if calls2 == 0 {
                XCTAssert(activity === firstActivity)
            }
            else if calls2 == 1 {
                exp2.fulfill()
            }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        // invalidate, to call again
        instance.onInvalidateActivity(activity: myActivity, id: myActivity.activityId)

        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected first callback to be called once")
        XCTAssert(calls2 >= 2, "expected second callback to be called at least twice")
    }
        
    func testOnInvalidateActivity() {
        let exp1 = self.expectation(description: "activity loaded")
        let exp2 = self.expectation(description: "activity loaded second time")
        
        // call
        var calls1 = 0
        let cancel1 = instance.useActivity(id: myActivity.activityId) { user in
            if calls1 == 0 { exp1.fulfill() }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        // repeat
        var calls2 = 0
        let cancel2 = instance.useActivity(id: myActivity.activityId) { user in
            if calls2 == 0 { exp2.fulfill() }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        // invalidate, call again
        instance.onInvalidateActivity(activity: myActivity, id: myActivity.activityId)
        
        XCTAssert(calls1 >= 1, "expected first callback to be called twice")
        XCTAssert(calls2 >= 1, "expected second callback to be called twice")
    }
    
    func testTriggerServerUpdateUser() {
        let exp1 = self.expectation(description: "user loaded")
        let exp2 = self.expectation(description: "user listener called again")

        var calls = 0
        let cancel1 = instance.useUser(id: me.uid) { user in
            if calls == 0 { exp1.fulfill() }
            if calls == 1 { exp2.fulfill() }
            calls += 1
        }
        cancels.append(cancel1)
        self.wait(for: [exp1], timeout: 2.0)
        
        instance.triggerServerUpdate(userId: me.uid, key: "name", value: "bob")
        self.waitForExpectations(timeout: 2.0)

        XCTAssert(calls >= 2, "expected callback to be called at least twice")
    }
    
    func testTriggerServerUpdateActivity() {
        let exp1 = self.expectation(description: "activity loaded")
        let exp2 = self.expectation(description: "activity listener called again")

        var calls = 0
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
            if calls == 0 { exp1.fulfill() }
            if calls == 1 { exp2.fulfill() }
            calls += 1
        }
        cancels.append(cancel1)
        self.wait(for: [exp1], timeout: 2.0)
        
        instance.triggerServerUpdate(activityId: myActivity.activityId, key: "title", value: "bob's birthday")
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls == 2, "expected callback to be called twice")
    }
}
