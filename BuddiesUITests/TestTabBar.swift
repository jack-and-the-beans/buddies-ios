//
//  TestTabBar.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/3/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var topicTabBtn: XCUIElement {
        return tabBars.buttons["DiscoverTabBtn"]
    }
}

class TestTabBar: BuddiesUITestCase {
    func testAllTabBarButtons() {
        login()
        
        let tabBarQuery = app.tabBars
        let topics = tabBarQuery.buttons["Topics"]
        
        XCTAssertTrue(topics.waitForExistence(timeout: 5))
        
        topics.tap()
        tabBarQuery.buttons["My Activities"].tap()
        tabBarQuery.buttons["Profile"].tap()
        tabBarQuery.buttons["Discover"].tap()
    }

}
