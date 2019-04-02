//
//  TestReport.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/1/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

class TestReport: BuddiesUITest {
    func testExample() {
        self.login()
        
        let app = XCUIApplication()
        app.tables.cells["activityCell0.0"].tap()
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
