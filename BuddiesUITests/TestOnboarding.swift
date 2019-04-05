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

class TestOnboarding: BuddiesUITestCase {
    func testLoginBase () {
        XCTAssertTrue(app.isDisplayingLoginBase)
        XCTAssertFalse(app.isDisplayingLoginExisting)
    }
    
    func testGoesToExisting () {
        app.haveAccountButton.tap()
        XCTAssertTrue(app.isDisplayingLoginExisting)
        XCTAssertFalse(app.isDisplayingLoginBase)
    }
    
    func testLogin(){
        self.login()
    }
}
