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
    
    override func setUp() {
        activityTableVC = ActivityTableVC()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        
        let comp = UserComponent()
        comp.image = UIImage()
        
        activityTableVC.users["user1"] = comp
        activityTableVC.users["user2"] = comp
        activityTableVC.users["user3"] = comp

        
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
        
        let comp = UserComponent()
        comp.image = UIImage()
        
        activityTableVC.users["user1"] = comp
        activityTableVC.users["user2"] = comp
        activityTableVC.users["user3"] = comp
        activityTableVC.users["user4"] = comp

        
        
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
    
    func testLoadDisplayIds(){
        XCTAssert(activityTableVC.getDisplayIds().sorted() == ["EgGiWaHiEKWYnaGW6cR3"].sorted(), "Displays are returned correctly. (Dummy function)")
    }
    
    func testGetActivity(){
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
        let comp = ActivityComponent()
        comp.activity = activity
        
        
        activityTableVC.activities = [comp, ActivityComponent(), ActivityComponent(), ActivityComponent()]
        let activities = activityTableVC.activities
        let indexPath = IndexPath(row: 0, section: 0)
        
        let resActivity = activityTableVC.getActivity(at: indexPath)
        XCTAssert(resActivity === activity, "getActivity fetches the right activity component")
        
        XCTAssert(activities.first !== activities.last, "Every fake ActivityComponent does not evaluate == with the others")
    }
    func testNumRows() {
        let count = 10
        activityTableVC.activities = [ActivityComponent](repeating: ActivityComponent(), count: count)
        XCTAssert(activityTableVC.tableView(UITableView(), numberOfRowsInSection: 0) == count)
        
        
    }
    
    func testNumSections(){
        XCTAssert(activityTableVC.numberOfSections(in: UITableView()) == 1)
    }

}
