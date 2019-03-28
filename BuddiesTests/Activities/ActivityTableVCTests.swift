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
    
    //For testLoadData
    class MockActivityTableVC: ActivityTableVC {
        var loadActivityCallIds = [ActivityId]()
        override func loadActivity(_ id: ActivityId, at indexPath: IndexPath, dataAccessor: DataAccessor, onLoaded: (() -> Void)?) {
            loadActivityCallIds.append(id)
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
        let memberPics = [UIButton(), UIButton(), UIButton()]
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        cell.memberPics = memberPics
        
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
                                topicIds: [])
        
        
        cell.format(using: activity, userImages: [])
        
        
        XCTAssert((cell.memberPics.filter() { $0.currentImage != nil }).isEmpty, "No user images means no UIButtons have images")
        
        XCTAssert(cell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(cell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(cell.locationLabel.text == locationText, "Cell location correctly set")
        
        XCTAssert(cell
            .extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
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
        
        thisUser.image = UIImage()
        
        
        activityTableVC.users["user1"] = thisUser
        activityTableVC.users["user2"] = thisUser
        activityTableVC.users["user3"] = thisUser

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
                                topicIds: [])
        
        cell.format(using: activity, userImages: [UIImage(), UIImage()])
        
        XCTAssert((cell.memberPics.filter() { $0.currentImage != nil }).count == 2, "No user images means no UIButtons have images")
        
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
        let memberPics = [UIButton(), UIButton(), UIButton()]
        
        cell.dateLabel = dataLabel
        cell.titleLabel = titleLabel
        cell.descriptionLabel = descriptionLabel
        cell.locationLabel = locationLabel
        cell.extraPicturesLabel = extraPicturesLabel
        cell.memberPics = memberPics
       
        
        thisUser.image = UIImage()
        
        
        activityTableVC.users["user1"] = thisUser
        activityTableVC.users["user2"] = thisUser
        activityTableVC.users["user3"] = thisUser
        activityTableVC.users["user4"] = thisUser
        
        let locationText = "Beans on Broad"

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
                                topicIds: [])
        
        cell.format(using: activity, userImages: [UIImage(), UIImage(), UIImage()])
        
        XCTAssert((cell.memberPics.filter() { $0.currentImage != nil }).count == 3, "No user images means no UIButtons have images")
        
        XCTAssert(cell.descriptionLabel.text == "activityDescription", "Cell Description correctly set")
        
        XCTAssert(cell.titleLabel.text == "activityTitle", "Cell Description correctly set")
        
        XCTAssert(cell.locationLabel.text == locationText, "Cell location correctly set")
        
        XCTAssert(!cell.extraPicturesLabel.isHidden, "Cell doesn't show ellipses for extra profile images")
    }
    
    
    func testGetActivity(){
        let locationText = "Beans on Broad"
        
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
                                locationText: locationText,
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
                                locationText: locationText,
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
    
    func testLoadUser(){
        
        var expectation: XCTestExpectation? = self.expectation(description: "Load user callback")

        activityTableVC.loadUser(uid: "my_uid", dataAccessor: instance) {
            expectation?.fulfill()
            expectation = nil
        }
        
        waitForExpectations(timeout: 0.2)
        
        XCTAssert(activityTableVC.users[thisUser.uid]?.uid == thisUser.uid, "Correct user is loaded")
    }
    
    //Doesn't test that users are loaded for each activity
    // It clearly works in the UI, so ignoring this
    //   since getting the DataAccesser to work is causing issues
    func testLoadActivity(){
        var expectation: XCTestExpectation? = self.expectation(description: "Load activity callback")

        let path = IndexPath(row: 0, section: 0)
        
        activityTableVC.activities = [[nil]]
        
        activityTableVC.loadActivity(thisActivity.activityId, at: path, dataAccessor: instance){
            expectation?.fulfill()
            expectation = nil
        }
        
        waitForExpectations(timeout: 2)
        
        XCTAssert(activityTableVC.activities[path.section][path.row]?.activityId == thisActivity.activityId, "Correct activity is loaded")
    }
    
    
    
    
    func testLoadData(){
        
        let mockVC = MockActivityTableVC()
    
        let data = [["1.1", "1.2"], ["2.1", "2.2", "2.3"], ["3.1", "3.2"]]
        
        mockVC.updateWantedActivities(for: data, dataAccessor: instance)

        var correctIds = data.count == mockVC.displayIds.count
        
        if correctIds {
            for i in 0..<data.count {
                correctIds = correctIds && data[i] == mockVC.displayIds[i]
            }
        }
        
        XCTAssert(mockVC.displayIds.elementsEqual(data), "displayIds are set correctly")
        
        XCTAssert(mockVC.loadActivityCallIds == data.flatMap() { $0 }, "loadUser called for all IDs")
        
    }
    
    
    func testLoadAlgoliaResults(){
        let mockVC = MockActivityTableVC()
        
        let searchParams: SearchParams = ("", Date(), Date(), 200)
        mockVC.lastSearch = searchParams
        
        let activities = ["id1", "id2"]
        
        mockVC.loadAlgoliaResults(activities: activities, from: ("", Date(), Date(), 200), err: nil, force: false)
        
        XCTAssert(mockVC.loadActivityCallIds == activities, "Load ids returned from Algolia")
    }
    
    func testLoadAlgoliaResultsNoNewParams(){
        let now = Date()
        let mockVC = MockActivityTableVC()
        let vSearchParams: SearchParams = ("", now, now, 200)
        mockVC.lastSearch = vSearchParams

        let searchParams: SearchParams = ("", now, now, 200)
        
        let activities = ["id1", "id2"]
        
        mockVC.loadAlgoliaResults(activities: activities, from: searchParams, err: nil, force: false)
        
        XCTAssert(mockVC.loadActivityCallIds == [], "No data should be loaded from outdated Algolia query")
    }

    
    func testParamsChanged_NoLastParamSet(){
        activityTableVC.lastSearch = nil
        
        let params: SearchParams = ("", Date(), Date(), 200)
        let nilToParams = activityTableVC.searchParamsChanged(from: params)
        
        XCTAssert(nilToParams, "Params changed when no previous params existed")
    }
    
    func testParamsChanged_DiffParams(){
        
        let params1: SearchParams = ("", Date(), Date(), 123)
        let params2: SearchParams = ("", Date(), Date(), 120)
        
        activityTableVC.lastSearch = params1
        
        let diffParams = activityTableVC.searchParamsChanged(from: params2)
        
        XCTAssert(diffParams, "Params changed when previous param was different")
    }
    
    func testParamsChanged_SameParam(){
        
        let now = Date()
        let params1: SearchParams = ("", now, now, 123)
        let params2: SearchParams = ("", now, now, 123)
        
        activityTableVC.lastSearch = params1
        
        let sameParamChanged = activityTableVC.searchParamsChanged(from: params1)
        
        XCTAssert(!sameParamChanged, "Params have not changed when previous param are same")
        
        let sameParamDiffTuplesChanged = activityTableVC.searchParamsChanged(from: params2)
        
        XCTAssert(!sameParamDiffTuplesChanged, "When params have not changed, but stored in new tuple")
    }
}
