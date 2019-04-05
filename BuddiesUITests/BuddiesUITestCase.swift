//
//  UITestHelpers.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/1/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

extension XCUIElement {
    var hasFocus: Bool {
        let hasKeyboardFocus = (self.value(forKey: "hasKeyboardFocus") as? Bool) ?? false
        return hasKeyboardFocus
    }
}

class BuddiesUITestCase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    func login(){
        app.buttons["haveAccount"].tap()
        
        let emailField = app.textFields["signInEmailField"]
        let passwordField = app.secureTextFields["signInPasswordField"]
        
        emailField.tap()
        XCTAssertTrue(emailField.hasFocus, "Password field is focused")
        emailField.typeText("UITest@test.com")
        
        passwordField.tap()
        XCTAssertTrue(passwordField.hasFocus, "Password field is focused")
        XCTAssertFalse(emailField.hasFocus, "Email field is no longer focused")
        passwordField.typeText("password")
        
        let loginButton = app.buttons["logIn"]
        
        //Hide keyboard
        loginButton.tap()
        XCTAssertTrue(loginButton.isHittable, "You still have to double-tap login for it to work")
        loginButton.tap()
    }
}
