//
//  BuddiesUITests.swift
//  BuddiesUITests
//
//  Created by Noah Allen on 3/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

extension XCUIApplication {
    var isDisplayingLoginBase: Bool {
        return otherElements["loginBase"].exists
    }
    var haveAccountButton: XCUIElement {
        return buttons["haveAccount"]
    }
    var isDisplayingLoginExisting: Bool {
        return otherElements["loginExistingVC"].exists
    }
}

class TestOnboarding: XCTestCase {
    var app: XCUIApplication!
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginBase () {
        XCTAssertTrue(app.isDisplayingLoginBase)
        XCTAssertFalse(app.isDisplayingLoginExisting)
    }
    
    func testGoesToExisting () {
        app.haveAccountButton.tap()
        XCTAssertTrue(app.isDisplayingLoginExisting)
        XCTAssertFalse(app.isDisplayingLoginBase)
    }
}
