//
//  DataAccessorTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
@testable import Buddies

class DataAccessorTests: XCTestCase {
    var cancels: [Canceler] = []
    var instance: DataAccessor!
    var me: Buddies.User!
    var myActivity: Activity!
    
    override func setUp() {
        // Create user stuff
        let uid = "my_uid"
        let usersCollection = MockCollectionReference()
        let meDoc = MockDocumentReference(docId: uid)
        meDoc.exposedData = [
            "image_url" : "image_url",
            "name" : "Test User",
            "bio" : "This is my bio\nDo you like it?",
            "email" : "fake@example.com",
            "date_joined" : Timestamp(date: Date())
        ]
        usersCollection.documents[uid] = meDoc
        
        // Create activity stuff
        let activityId = "my_activity"
        let activitiesCollection = MockCollectionReference()
        let activityDoc = MockDocumentReference(docId: activityId)
        activityDoc.exposedData = [
            "members": [],
            "location": GeoPoint(latitude: 10.0, longitude: 10.0),
            "date_created": Timestamp(date: Date()),
            "owner_id": uid,
            "title": "My Event",
            "topic_ids": [],
            "start_time": Timestamp(date: Date()),
            "end_time": Timestamp(date: Date()),
        ]
        activitiesCollection.documents[activityId] = activityDoc
        
        // Create the instance to test
        instance = DataAccessor(usersCollection: usersCollection,
                                activitiesCollection: activitiesCollection)
        
        // Create User object manually, no caching!
        let userSnap = MockDocumentSnapshot(data: meDoc.exposedData, docId: uid)
        self.me = Buddies.User.from(snap: userSnap, with: instance)
        
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
        
        // call
        var calls1 = 0
        let cancel1 = instance.useUser(id: me.uid) { user in
            // Check some props were loaded
            XCTAssert(user.uid == self.me.uid)
            XCTAssert(user.imageUrl == self.me.imageUrl)
            XCTAssert(user.shouldSendActivitySuggestionNotification == self.me.shouldSendActivitySuggestionNotification)
            
            exp1.fulfill()
            calls1 += 1
        }
        
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected callback to be called once")
    }
    
    func testUseUserAfterCacheMiss() {
        // first call
        let exp1 = self.expectation(description: "user loaded")
        var calls1 = 0
        let cancel1 = instance.useUser(id: me.uid) { user in
            if calls1 == 0 {
                exp1.fulfill()
            }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
        
        instance._userCache.removeAllObjects()
        
        // repeat
        let exp2 = self.expectation(description: "user loaded second time")
        var calls2 = 0
        let cancel2 = instance.useUser(id: me.uid) { user in
            exp2.fulfill()
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 2, "expected first callback to be called twice")
        XCTAssert(calls2 == 1, "expected second callback to be called once")
    }
    
    func testUseUserAfterCancel() {
        // first call
        let exp1 = self.expectation(description: "user loaded")
        var calls1 = 0
        var firstUser: Buddies.User?
        let cancel1 = instance.useUser(id: me.uid) { user in
            firstUser = user
            exp1.fulfill()
            calls1 += 1
        }
        
        self.waitForExpectations(timeout: 2.0)
        
        // Manually call cancel function
        cancel1()
        
        // repeat
        let exp2 = self.expectation(description: "user loaded second time")
        var calls2 = 0
        let cancel2 = instance.useUser(id: me.uid) { user in
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
        instance.onInvalidateUser(user: me)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected first callback to be called once")
        XCTAssert(calls2 >= 2, "expected second callback to be called at least twice")
    }
    
    func testUseUserTwice() {
        // first call
        let exp1 = self.expectation(description: "user loaded")
        var calls1 = 0
        var firstUser: Buddies.User?
        let cancel1 = instance.useUser(id: me.uid) { user in
            firstUser = user
            exp1.fulfill()
            calls1 += 1
        }
        cancels.append(cancel1)

        self.waitForExpectations(timeout: 2.0)
        
        // repeat
        let exp2 = self.expectation(description: "user loaded second time")
        var calls2 = 0
        let cancel2 = instance.useUser(id: me.uid) { user in
            XCTAssert(user === firstUser)
            exp2.fulfill()
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected first callback to be called once")
        XCTAssert(calls2 == 1, "expected second callback to be called once")
    }
    
    func testOnInvalidateUser() {
        let exp1 = self.expectation(description: "user loaded")
        let exp2 = self.expectation(description: "user loaded second time")
        
        // call
        var calls1 = 0
        let cancel1 = instance.useUser(id: me.uid) { user in
            if calls1 == 0 { exp1.fulfill() }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        // repeat
        var calls2 = 0
        let cancel2 = instance.useUser(id: me.uid) { user in
            if calls2 == 0 { exp2.fulfill() }
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        // invalidate, to call again
        instance.onInvalidateUser(user: me)
        
        XCTAssert(calls1 == 2, "expected first callback to be called twice")
        XCTAssert(calls2 == 2, "expected second callback to be called twice")
    }
    
    func testUseActivity() {
        let exp1 = self.expectation(description: "activity loaded")
        
        // call
        var calls1 = 0
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
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
    
    func testUseActivityTwice() {
        // first call
        let exp1 = self.expectation(description: "activity loaded")
        var calls1 = 0
        var firstActivity: Activity?
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
            firstActivity = activity
            exp1.fulfill()
            calls1 += 1
        }
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)
        
        // repeat
        let exp2 = self.expectation(description: "activity loaded second time")
        var calls2 = 0
        let cancel2 = instance.useActivity(id: myActivity.activityId) { activity in
            XCTAssert(activity === firstActivity)
            exp2.fulfill()
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected first callback to be called once")
        XCTAssert(calls2 == 1, "expected second callback to be called once")
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
        instance.onInvalidateActivity(activity: myActivity)

        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 1, "expected first callback to be called once")
        XCTAssert(calls2 >= 2, "expected second callback to be called at least twice")
    }
    
    func testUseActivityAfterCacheMiss() {
        // first call
        let exp1 = self.expectation(description: "activity loaded")
        var calls1 = 0
        let cancel1 = instance.useActivity(id: myActivity.activityId) { activity in
            if calls1 == 0 {
                exp1.fulfill()
            }
            calls1 += 1
        }
        cancels.append(cancel1)
        
        self.waitForExpectations(timeout: 2.0)

        instance._activityCache.removeAllObjects()
        
        // repeat
        let exp2 = self.expectation(description: "activity loaded second time")
        var calls2 = 0
        let cancel2 = instance.useActivity(id: myActivity.activityId) { activity in
            exp2.fulfill()
            calls2 += 1
        }
        cancels.append(cancel2)
        
        self.waitForExpectations(timeout: 2.0)
        
        XCTAssert(calls1 == 2, "expected first callback to be called twice")
        XCTAssert(calls2 == 1, "expected second callback to be called once")
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
        instance.onInvalidateActivity(activity: myActivity)
        
        XCTAssert(calls1 == 2, "expected first callback to be called twice")
        XCTAssert(calls2 == 2, "expected second callback to be called twice")
    }
    
    func testIsUserCached() {
        let result1 = instance.isUserCached(id: me.uid)
        XCTAssertFalse(result1)
        
        let exp = self.expectation(description: "user loaded")
        let cancel = instance.useUser(id: me.uid) { user in
            exp.fulfill()
        }
        cancels.append(cancel)
        
        self.waitForExpectations(timeout: 2.0)
        
        let result2 = instance.isUserCached(id: me.uid)
        XCTAssertTrue(result2)
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

        XCTAssert(calls == 2, "expected callback to be called twice")
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
