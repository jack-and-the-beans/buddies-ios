//
//  TestReport.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/1/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

class TestReport: BuddiesUITest {
    func testReportButton() {
        self.login()
    
        let topCell = app.tables/*@START_MENU_TOKEN@*/.cells["activityCell0.0"]/*[[".cells[\"hfdg, Hey, London, PA, United States, Through Tomorrow\"]",".cells[\"activityCell0.0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        XCTAssertTrue(waitForElementToAppear(topCell, timeout: 30), "top activity cell never appeared (30 second timeout)")
    
        topCell.tap()
    
        app.navigationBars["View Activity"]/*@START_MENU_TOKEN@*/.buttons["reportActivity"]/*[[".buttons[\"Report\"]",".buttons[\"reportActivity\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
        let reportActivityNavigationBar = app.navigationBars["Report Activity"]
        let sendButton = reportActivityNavigationBar.buttons["Send"]
        //It gets really angry when I try to use the "Cancel" button
        sendButton.tap()
        XCTAssertTrue(sendButton.isHittable, "Nothing typed, so Send does nothing")
    }

}
