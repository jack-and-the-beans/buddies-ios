//
//  ActivityTableDataListenerTest.swift
//  BuddiesTests
//
//  Created by Noah Allen on 3/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import Buddies

class ActivityTableDataListenerTest: XCTestCase {
    let testActivity = Activity(delegate: nil,
                                activityId: "my_activity",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                locationText: "What up buddy",
                                bannedUsers: [],
                                topicIds: [])

    var dataAccessor: DataAccessor!
    var delly: TestListenerDelly!
    var listener: ActivityTableDataListener!
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
        dataAccessor = DataAccessor(
            usersCollection: usersCollection,
            accountCollection: usersCollection,
            activitiesCollection: activitiesCollection,
            storageManager: MockStorageManager(),
            addChangeListener: { listener in
                listener(Auth.auth(), user)
                return NSObject()
        },
            removeChangeListener: { handle in /*do nothing*/ })
        
        self.delly = TestListenerDelly()
        self.listener = ActivityTableDataListener()
        listener.delegate = delly
    }

    class TestListenerDelly: ActivityTableDataDelegate {
        var calledUpdate = false
        var updateExp = XCTestExpectation(description: "Updated activity")
        var updatedActivity = ""
        func updateActivityInSection(activity: Activity, section: Int) {
            calledUpdate = true
            updatedActivity = activity.activityId
            updateExp.fulfill()
        }
        
        var calledNewActivities = false
        var newActivities = [[String]]()
        var newExp = XCTestExpectation(description: "Called new activities")
        func onNewActivities(newActivities: [[Activity]]) {
            calledNewActivities = true
            self.newActivities = newActivities.map { $0.map { $0.activityId } }
            newExp.fulfill()
        }
        
        var calledRemove = false
        var removeExp = XCTestExpectation(description: "Removed activity")
        var removedActivitiy: String = ""
        func removeActivityInSection(id: ActivityId, section: Int) {
            calledRemove = true
            removedActivitiy = id
            removeExp.fulfill()
        }
        
        var calledOpsFinished = false
        func onOperationsFinished() {
            calledOpsFinished = true
        }
    }

    func testGetStringsInOrder () {
        let listener = ActivityTableDataListener()
        let ids = [["b"], ["c"], ["a", "d"]]
        let res = listener.getStringsInOrder(ids)
        let expected = ["a", "b", "c", "d"]
        XCTAssertTrue(res == expected)
    }

    func testTrimActivities () {
        let listener = ActivityTableDataListener()

        let list: [[Activity?]] = [[testActivity], [nil], [testActivity]]
        let res = listener.trimActivities(list)
        XCTAssertTrue(res[1].count == 0, "Should remove nil activity")
        XCTAssertTrue(res[0].count == 1, "Should retain non-nil activity")
    }
    
    func testCleanup () {
        let listener = ActivityTableDataListener()
        let exp = expectation(description: "called canceler")
        var called = false
        let canceler: () -> Void = {
            called = true
            exp.fulfill()
        }
        listener.cancelers += [canceler]
        listener.cleanup()
        waitForExpectations(timeout: 2.0)
        XCTAssert(called, "canceler should be called")
    }
    
    func testUpdateSameIds() {
        listener.wantedActivities = [["hi"]]
        listener.updateWantedActivities(with: [["hi"]])
        XCTAssertTrue(delly.calledOpsFinished)
        XCTAssertFalse(delly.calledNewActivities)
    }
    
    func testGetNilActivity() {
        listener.updateWantedActivities(with: [["my_activity", "NO"]], dataAccessor: dataAccessor)
        XCTAssertTrue(listener.wantedActivities == [["my_activity", "NO"]])
        wait(for: [delly.newExp], timeout: 2.0)
        XCTAssertTrue(delly.newActivities[0].contains("my_activity"), "has non-nil activity")
        XCTAssertFalse(delly.newActivities[0].contains("NO"), "does not have nil activity")
    }

    func testSetupOfActivities() {
        listener.updateWantedActivities(with: [["my_activity"]], dataAccessor: dataAccessor)
        XCTAssertTrue(listener.wantedActivities == [["my_activity"]])
        wait(for: [delly.newExp], timeout: 2.0)
        XCTAssertTrue(delly.newActivities[0].contains("my_activity"), "Handled activity!")
    }

    func testUpdateActivityWithData() {
        listener.updateWantedActivities(with: [["my_activity"]], dataAccessor: dataAccessor)
        XCTAssertTrue(listener.wantedActivities == [["my_activity"]])
        wait(for: [delly.newExp], timeout: 2.0)
        // Tell the accessor to perform an update:
        dataAccessor.onInvalidateActivity(activity: testActivity, id: "my_activity")
        wait(for: [delly.updateExp], timeout: 2.0)
        XCTAssertTrue(delly.updatedActivity == "my_activity")
    }
    
    func testUpdateActivityWithNil() {
        listener.updateWantedActivities(with: [["my_activity"]], dataAccessor: dataAccessor)
        XCTAssertTrue(listener.wantedActivities == [["my_activity"]])
        wait(for: [delly.newExp], timeout: 2.0)
        // Tell the accessor to perform an update with a nil activity:
        dataAccessor.onInvalidateActivity(activity: nil, id: "my_activity")
        wait(for: [delly.removeExp], timeout: 2.0)
        XCTAssertTrue(delly.removedActivitiy == "my_activity")
    }
}
