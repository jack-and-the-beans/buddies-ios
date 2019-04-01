//
//  ActivityListTest.swift
//  BuddiesTests
//
//  Created by Noah Allen on 3/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseAuth
@testable import Buddies

class ActivityListTest: XCTestCase {
    let fakeTable = UITableView()
    let testActivity = Activity(delegate: nil,
                                activityId: "test_id",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                locationText: "What up buddy",
                                topicIds: [])

    func createActivity(id: String) -> Activity {
        return Activity(delegate: nil,
                 activityId: id,
                 dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                 members: ["user1", "user2"],
                 location: GeoPoint(latitude: 1, longitude: 2),
                 ownerId: "ownerId",
                 title: "activityTitle",
                 description: "activityDescription",
                 startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                 endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                 locationText: "What up buddy",
                 topicIds: [])
    }

    func testNumSections () {
        let list = ActivityList()
        XCTAssertTrue(list.numberOfSections(in: fakeTable) == 0)
    }
    
    func testNumRows () {
        let list = ActivityList()
        list.activities = [[]]
        list.activities[0] = [testActivity, testActivity]
        XCTAssertTrue(list.tableView(fakeTable, numberOfRowsInSection: 0) == 2)
    }
    
    func testHasNoActivities () {
        let list = ActivityList()
        XCTAssertTrue(list.hasNoActivities())
        list.activities = [[]]
        list.activities[0] = [testActivity, testActivity]
        XCTAssertFalse(list.hasNoActivities())
    }
    
    func testGet () {
        let list = ActivityList()
        list.activities = [[testActivity]]
        let activity = list[activityAt: IndexPath(row: 0, section: 0)]
        XCTAssertTrue(activity.activityId == testActivity.activityId)
    }

    func testRemove () {
        let list = ActivityList()
        list.activities = [[testActivity]]
        if let path = list.removeActivityInSection(id: testActivity.activityId, section: 0) {
            XCTAssertTrue(path.row == 0)
        }
        XCTAssertNil(list.removeActivityInSection(id: testActivity.activityId, section: 0))
    }
    
    func testUpdate () {
        let list = ActivityList()
        list.activities = [[testActivity]]
        if let res = list.updateActivityInSection(activity: testActivity, section: 0) {
            XCTAssertTrue(res.row == 0)
        }
        XCTAssertNil(list.updateActivityInSection(activity: testActivity, section: 1))
        let activity = createActivity(id: "NO")
        XCTAssertNil(list.updateActivityInSection(activity: activity, section: 0))
    }
    
    func testGetSectionHeader () {
        let list = ActivityList()
        let headers = ["hi"]
        list.setSectionHeaders(headers)
        let res = list.tableView(fakeTable, titleForHeaderInSection: 0)
        XCTAssertTrue(res == "hi")
        let res2 = list.tableView(fakeTable, titleForHeaderInSection: 1)
        XCTAssertNil(res2)
    }
    
    func testSetSectionHeader () {
        let list = ActivityList()
        let headers = ["hi"]
        list.setSectionHeaders(headers)
        XCTAssertTrue(list.sectionHeaders.contains("hi"))
    }
    
    func testSetActivitiesNewResults() {
        let list = ActivityList()
        let activities = [[testActivity, testActivity]]
        let res = list.setActivities(activities)
        XCTAssertNil(res, "no results when no acitvities were removed")
        XCTAssertTrue(list.activities[0][0].activityId == testActivity.activityId)
    }
    
    func testSetActivitiesRemovedResults() {
        let list = ActivityList()
        let oldActivity = createActivity(id: "old")
        let newActivity = createActivity(id: "new")
        list.activities = [[oldActivity, newActivity]]
        let res = list.setActivities([[newActivity]])
        XCTAssertTrue((res?[0].row ?? 1) == 0)
    }
}
