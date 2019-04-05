//
//  TestReport.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/1/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

class TestActivity: BuddiesUITestCase {
    
    func useOtherActivity(){
        let topCell = app.tables/*@START_MENU_TOKEN@*/.cells["activityCell0.0"]/*[[".cells[\"hfdg, Hey, London, PA, United States, Through Tomorrow\"]",".cells[\"activityCell0.0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(topCell.waitForExistence(timeout: 30), "top activity cell never appeared (30 second timeout)")
        
        topCell.tap()
        
        app.navigationBars["View Activity"]/*@START_MENU_TOKEN@*/.buttons["reportActivity"]/*[[".buttons[\"Report\"]",".buttons[\"reportActivity\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let reportActivityNavigationBar = app.navigationBars["Report Activity"]
        let sendButton = reportActivityNavigationBar.buttons["Send"]
        //It gets really angry when I try to use the "Cancel" button
        sendButton.tap()
        XCTAssertTrue(sendButton.isHittable, "Nothing typed, so Send does nothing")
        
        
        reportActivityNavigationBar.buttons["Cancel"].tap()
        
        print(app.debugDescription)
        
        let joinBtn = app.buttons["joinActivity"]
        
        XCTAssertTrue(joinBtn.waitForExistence(timeout: 5), "Can't find the join button")
        
        joinBtn.tap()
        
        let activityDescription = app.otherElements["activityDescriptionFull"]
        
        XCTAssertTrue(activityDescription.waitForExistence(timeout: 20), "Can't find the activity description")
        
        activityDescription.tap()
        
        let leaveBtn = app.buttons["Leave Activity"]
        
        XCTAssertTrue(leaveBtn.waitForExistence(timeout: 10), "Can't find the leave activity button")
        
        leaveBtn.tap()
        
        let alertLeave = app.alerts["Leave Activity"].buttons["Leave"]
        XCTAssertTrue(alertLeave.waitForExistence(timeout: 5), "Can't confirmation alert to leave the activity")

        alertLeave.tap()
        
        
    }
    
    func useOwnActivity(){
        let myActivitiesTab = app.tabBars.buttons["My Activities"]
        
        XCTAssertTrue(myActivitiesTab.waitForExistence(timeout: 5), "Can't find button for MyActivities")
        
        myActivitiesTab.tap()
        
        let topCreatedActivity = app.tables/*@START_MENU_TOKEN@*/.cells["activityCell0.0"]/*[[".cells[\"hfdg, Hey, London, PA, United States, Through Tomorrow\"]",".cells[\"activityCell0.0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        XCTAssertTrue(topCreatedActivity.waitForExistence(timeout: 20), "Can't find a top CreatedActivity")
        
        topCreatedActivity.tap()
        
        let activityDescription = app.otherElements["activityDescriptionFull"]
        
        XCTAssertTrue(activityDescription.waitForExistence(timeout: 20), "Can't find the activity description")
        
        activityDescription.tap()
        
        let topMember = app/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"activityDescriptionFull\"]",".otherElements[\"descriptionNestedView\"].collectionViews",".collectionViews"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.cells["activityMember0"].otherElements.children(matching: .button).element
        
        XCTAssertTrue(topMember.waitForExistence(timeout: 10), "Can't find a user in this activity")
        
        topMember.tap()
        
        app.navigationBars["Profile"].buttons["View Activity"].tap()
        
        
        let deleteBtn = app.buttons["deleteActivity"]
        
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 10), "Can't find the leave activity button")
        
        deleteBtn.tap()
        
        let alerteCancelDelete = app.alerts["Delete Activity"].buttons["Cancel"]
        XCTAssertTrue(alerteCancelDelete.waitForExistence(timeout: 5), "Can't confirmation alert to delete the activity")
        
        alerteCancelDelete.tap()
        
        app.navigationBars["View Activity"].buttons["editActivity"].tap()
        app.navigationBars["Edit Activity"].buttons["Save"].tap()
        
        //TODO: This is a bug with chat.  It hides the ^ button.  Commented out for now.
        //let shrinkBtn = app.buttons["shrinkMe"]
        
        //XCTAssert(shrinkBtn.waitForExistence(timeout: 10), "Shrink button should exist")
        
        //XCTAssertTrue(shrinkBtn.isHittable, "Shrink button should be hittable")
        
        //app.buttons["shrinkMe"].tap()
    }
    
    func testActivitiesAndReport() {
        login()

        //MARK: - Test activity I don't own
        useOtherActivity()

                        
        //MARK: - Test activity I DO own.
        useOwnActivity()
    }

}
