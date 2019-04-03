//
//  TestProfile.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/3/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

class TestProfile: BuddiesUITestCase {

    func testEditProfile() {
        login()
        let profile = app.tabBars.buttons["Profile"]
        
        XCTAssertTrue(waitForElementToAppear(profile, timeout: 15), "Profile tab button appears")
        print(app.debugDescription)
        profile.tap()

        
        let profileNavigationBar = app.navigationBars["Profile"]
        let settingsBtn = profileNavigationBar.buttons["Settings"]
        
        XCTAssertTrue(waitForElementToAppear(settingsBtn, timeout: 5), "Settings button appears on Profile")
        
        settingsBtn.tap()
        
        app.navigationBars["Settings"].buttons["Profile"].tap()
        
        let editButton = profileNavigationBar.buttons["Edit"]
        editButton.tap()
        app.buttons["Cancel"].tap()
        editButton.tap()
        app.buttons["Save"].tap()
        
    }

}
