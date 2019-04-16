//
//  ActivityVCTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/18/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies
import FirebaseFirestore
import UIKit

class ActivityTableVCTests: XCTestCase {
    
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
                                bannedUsers: [],
                                topicIds: [])
  
    // For testLoadData
    class MockActivityTableVC: ActivityTableVC {
        var didCallFetch = false
        override func fetchAndLoadActivities() {
            didCallFetch = true
        }
        var didTrySegue = false
        override func performSegue(withIdentifier identifier: String, sender: Any?) {
            didTrySegue = true
        }
    }

    var activityTableVC: ActivityTableVC!
    var instance: DataAccessor!
    var thisUser: User!
    var storageManager: MockStorageManager!
    var thisActivity: Activity!
    
    func setupDataAccessor() {
        
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
            "members": [uid],
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
                                accountCollection: usersCollection,
                                activitiesCollection: activitiesCollection)
        
        thisUser = LoggedInUser.from(snap: MockDocumentSnapshot(data: meDoc.exposedData, docId: uid), with: instance)
        thisActivity = Activity.from(snap: MockDocumentSnapshot(data: activityDoc.exposedData, docId: activityId), with: instance)
        
    }
    
    override func setUp() {
        activityTableVC = ActivityTableVC()
        
        storageManager = MockStorageManager()

        
        setupDataAccessor()
    }

    func testCellFormat_NoImages() {
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        let image = UIImageView()
        let image2 = UIImageView()
        let image3 = UIImageView()
        cell.pic1 = image
        cell.pic2 = image2
        cell.pic3 = image3

        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        
        let locationText = "Beans on Broad"
        
        let activity = Activity(delegate: nil,
                                activityId: "test_id",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                locationText: locationText,
                                bannedUsers: [],
                                topicIds: [])
        
        
        cell.format(using: activity)

        XCTAssertNil(cell.pic1.image, "The first image should not be set")
        
        XCTAssert(cell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(cell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(cell.locationLabel.text == locationText, "Cell location correctly set")
        
        XCTAssert(cell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    func testCellFormat_SomeImages() {
        
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        let image = UIImageView()
        let image2 = UIImageView()
        let image3 = UIImageView()
        cell.pic1 = image
        cell.pic2 = image2
        cell.pic3 = image3
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel

        thisUser.image = UIImage()
        let locationText = "Beans"
        let activity = Activity(delegate: nil,
                                activityId: "test_id",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                locationText: locationText,
                                bannedUsers: [],
                                topicIds: [])
        activity.users = [thisUser]
        cell.format(using: activity)
        
        XCTAssertNotNil(cell.pic1.image, "The first image should be set")
        XCTAssertNil(cell.pic2.image, "The second image should not be set")

        XCTAssert(cell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(cell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(cell.locationLabel.text == locationText, "Cell location correctly set")
        
        XCTAssert(cell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    func testCellFormat_TooManyImages() {
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        let image = UIImageView()
        let image2 = UIImageView()
        let image3 = UIImageView()
        cell.pic1 = image
        cell.pic2 = image2
        cell.pic3 = image3
        
        thisUser.image = UIImage()
        let locationText = "beans"
        let activity = Activity(delegate: nil,
                                activityId: "test_id",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2", "user3", "user4"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                locationText: locationText,
                                bannedUsers: [],
                                topicIds: [])
        
        activity.users = [thisUser, thisUser, thisUser, thisUser]
        cell.format(using: activity)
        
        XCTAssertNotNil(cell.pic1.image, "The first image should be set")
        XCTAssertNotNil(cell.pic2.image, "The second image should be set")
        XCTAssertNotNil(cell.pic3.image, "The third image should be set")

        XCTAssert(cell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(cell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(cell.locationLabel.text == locationText, "Cell location correctly set")
        
        XCTAssert(!cell.extraPicturesLabel.isHidden, "Should show elipses for > 3 users")
    }
    
    func testConfigureRefreshControl () {
        activityTableVC.configureRefreshControl()
        XCTAssertNotNil(activityTableVC.refreshControl)
    }

    func testStartRefreshIndicator () {
        activityTableVC.startRefreshIndicator()
        XCTAssertTrue( activityTableVC.refreshControl?.isRefreshing ?? false )
    }
    
    func testHandleRefreshControl () {
        let vc = MockActivityTableVC()
        vc.handleRefreshControl()
        XCTAssertTrue( vc.didCallFetch, "Should call fetch and load on refresh control" )
    }
    
    func testUpdateWantedActivities () {
        activityTableVC.updateWantedActivities(with: [["hello"]])
        let ids = activityTableVC.dataManager.wantedActivities.flatMap { $0.map { $0 } }
        XCTAssertTrue( ids.contains("hello"))
    }
    
    func testOpsFinished () {
        activityTableVC.startRefreshIndicator()
        XCTAssertTrue(activityTableVC.refreshControl?.isRefreshing ?? false)
        activityTableVC.onOperationsFinished()
        XCTAssertFalse(activityTableVC.refreshControl?.isRefreshing ?? true)
    }
    
    func testNoActivities () {
        activityTableVC.checkAndShowNoActivitiesMessage()
        let text = activityTableVC.tableView.backgroundView
        XCTAssertNotNil(text, "Text view should exist")

        // Add an activity:
        let _ = activityTableVC.dataSource.setActivities([[testActivity]])
        activityTableVC.checkAndShowNoActivitiesMessage()
        let text2 = activityTableVC.tableView.backgroundView
        XCTAssertNil(text2, "Text view should not exist")
    }
    
    func testSelectRow () {
        let vc = MockActivityTableVC()
        let _ = vc.dataSource.setActivities([[testActivity]])
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(vc.didTrySegue)
    }
}
