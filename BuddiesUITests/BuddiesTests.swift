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

class BuddiesUITest: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    func login(){
        app/*@START_MENU_TOKEN@*/.buttons["haveAccount"]/*[[".otherElements[\"loginBase\"]",".buttons[\"havingAccount\"]",".buttons[\"haveAccount\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let emailField = app/*@START_MENU_TOKEN@*/.textFields["signInEmailField"]/*[[".otherElements[\"loginExistingVC\"]",".textFields[\"Email\"]",".textFields[\"signInEmailField\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        let passwordField = app/*@START_MENU_TOKEN@*/.secureTextFields["signInPasswordField"]/*[[".otherElements[\"loginExistingVC\"]",".secureTextFields[\"Password\"]",".secureTextFields[\"signInPasswordField\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        
        emailField.tap()
        XCTAssertTrue(emailField.hasFocus, "Password field is focused")
        emailField.typeText("UITest@test.com")
        
        passwordField.tap()
        XCTAssertTrue(passwordField.hasFocus, "Password field is focused")
        XCTAssertFalse(emailField.hasFocus, "Email field is no longer focused")
        passwordField.typeText("password")
        
        let loginButton = app/*@START_MENU_TOKEN@*/.buttons["logIn"]/*[[".otherElements[\"loginExistingVC\"]",".buttons[\"Log In\"]",".buttons[\"logIn\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        
        //Hide keyboard
        loginButton.tap()
        XCTAssertTrue(loginButton.isHittable, "You still have to double-tap login for it to work")
        loginButton.tap()
    }
}
