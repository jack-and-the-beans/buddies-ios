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

    var activityTableVC: ActivityTableVC!
    var instance: DataAccessor!
    
    override func setUp() {
        activityTableVC = ActivityTableVC()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
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
                                activitiesCollection: activitiesCollection)
        
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCellFormat_NoImages() {
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        let memberPics = [UIButton(), UIButton(), UIButton()]
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        cell.memberPics = memberPics
        
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
                                topicIds: [])
        
        let resCell = activityTableVC.format(cell: cell, using: activity, at: IndexPath(index: 0))
        
        XCTAssert((resCell.memberPics.filter() { $0.currentImage != nil }).isEmpty, "No user images means no UIButtons have images")
        
        XCTAssert(resCell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(resCell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(resCell.locationLabel.text == "\(Double(1)), \(Double(2))", "Cell location correctly set")
        
        XCTAssert(resCell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    func testCellFormat_SomeImages() {
        
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        let memberPics = [UIButton(), UIButton(), UIButton()]
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        cell.memberPics = memberPics
        
        
        activityTableVC.userImages["user1"] = UIImage()
        activityTableVC.userImages["user2"] = UIImage()
        activityTableVC.userImages["user3"] = UIImage()

        
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
                                topicIds: [])
        
        let resCell = activityTableVC.format(cell: cell, using: activity, at: IndexPath(index: 0))
        
        XCTAssert((resCell.memberPics.filter() { $0.currentImage != nil }).count == 2, "No user images means no UIButtons have images")
        
        XCTAssert(resCell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(resCell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(resCell.locationLabel.text == "\(Double(1)), \(Double(2))", "Cell location correctly set")
        
        XCTAssert(resCell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    func testCellFormat_TooManyImages() {
        let cell = ActivityCell()
        
        let dataLabel = UILabel()
        let titleLabel = UILabel()
        let descriptionLabel = UILabel()
        let locationLabel = UILabel()
        let extraPicturesLabel = UILabel()
        let memberPics = [UIButton(), UIButton(), UIButton()]
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        cell.memberPics = memberPics
        
        activityTableVC.userImages["user1"] = UIImage()
        activityTableVC.userImages["user2"] = UIImage()
        activityTableVC.userImages["user3"] = UIImage()
        activityTableVC.userImages["user4"] = UIImage()
        
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
                                topicIds: [])
        
        let resCell = activityTableVC.format(cell: cell, using: activity, at: IndexPath(index: 0))
        
        XCTAssert((resCell.memberPics.filter() { $0.currentImage != nil }).count == 3, "No user images means no UIButtons have images")
        
        XCTAssert(resCell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(resCell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(resCell.locationLabel.text == "\(Double(1)), \(Double(2))", "Cell location correctly set")
        
        XCTAssert(!resCell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    
    func testGetActivity(){
        let activity = Activity(delegate: nil,
                                activityId: "test_id1",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2", "user3", "user4"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                topicIds: [])
        
        let activity2 = Activity(delegate: nil,
                                activityId: "test_id2",
                                dateCreated: Timestamp(date: "11/23/1998".toDate()!.date),
                                members: ["user1", "user2", "user3", "user4"],
                                location: GeoPoint(latitude: 1, longitude: 2),
                                ownerId: "ownerId",
                                title: "activityTitle",
                                description: "activityDescription",
                                startTime: Timestamp(date: "11/23/1998".toDate()!.date),
                                endTime: Timestamp(date: "11/24/1998".toDate()!.date),
                                topicIds: [])
        
        activityTableVC.activities = [[activity, activity2]]
    
        let indexPath = IndexPath(row: 0, section: 0)
        
        let resActivity = activityTableVC.getActivity(at: indexPath)
        XCTAssert(resActivity === activity, "getActivity fetches the right activity component")
        
    }
    func testNumRows() {
        let count = 10
        activityTableVC.displayIds = [[String](repeating: "ex", count: count)]
        XCTAssert(activityTableVC.tableView(UITableView(), numberOfRowsInSection: 0) == count)
    }
    
    func testNumSections(){
        activityTableVC.displayIds = [[],[]]
        XCTAssert(activityTableVC.numberOfSections(in: UITableView()) == 2)
    }
    
    func testCleanup () {
        var userCancels = 0
        let userCancelsPerActivity = 5
        activityTableVC.userCancelers["fakeActivity"] = [Canceler](repeating: { userCancels += 1}, count: userCancelsPerActivity)
        activityTableVC.userCancelers["fakeActivity2"] = [Canceler](repeating: { userCancels += 1}, count: userCancelsPerActivity)
        
        var activityCancels = 0
        let totalActivityCancels = 10
        activityTableVC.activityCancelers = [Canceler](repeating: { activityCancels += 1}, count: totalActivityCancels)
        
        activityTableVC.cleanup()
        
        XCTAssert(userCancels == userCancelsPerActivity*2, "Each user canceler is called during cleanup")
        XCTAssert(activityCancels == totalActivityCancels, "Each activity canceler is called during cleanup")
       
        XCTAssert(activityTableVC.userCancelers.isEmpty, "No remaining/nil'd user cancels remain after cleanup")
        XCTAssert(activityTableVC.activityCancelers.isEmpty, "No remaining/nil'd activity cancels remain after cleanup")

    }
    
    func testLoadData(){
        let storageManager = MockStorageManager()
    
        activityTableVC.loadData(for: [["my_activity"]], dataAccessor: instance, storageManager: storageManager)
        
        
        
    }

}
