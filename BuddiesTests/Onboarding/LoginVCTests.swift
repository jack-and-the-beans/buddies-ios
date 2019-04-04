//
//  LoginBaseTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class LoginVCTests: XCTestCase {
    var vc: LoginVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.Login.viewController(withID: "create")
        UIApplication.setRootView(vc, animated: false)
        _ = vc.view // Make sure view is loaded
    }
    
    override func tearDown() {
        UIApplication.shared.keyWindow?.rootViewController = nil
        vc = nil
    }
    
    func testInitLifecycle() {
        XCTAssertNotNil(vc.view, "View should be loaded")
    }
    
    func testGetTopField() {
        XCTAssertNotNil(vc.getTopField(), "Top field shouldn't be nil")
    }
    
    func testKeyboardWillShow() {
        let height = 10
        let rect = CGRect(x: 0, y: 0, width: 0, height: height)
        let info = [ UIResponder.keyboardFrameBeginUserInfoKey: NSValue(cgRect: rect) ]
        let notif = NSNotification(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: info)
        
        vc.keyboardWillShow(notification: notif)
        
        XCTAssert(
            vc.view!.frame.origin.y == CGFloat(integerLiteral: -1 * height),
            "KeyboardWillShow should shift view")
    }
    
    func testKeyboardWillHide() {
        // Show the keyboard
        let rect = CGRect(x: 0, y: 0, width: 0, height: 10)
        let info = [ UIResponder.keyboardFrameBeginUserInfoKey: NSValue(cgRect: rect) ]
        let showNotif = Notification(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: info)
        
        NotificationCenter.default.post(showNotif)
        
        // Hide it!
        let hideNotif = Notification(name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.post(hideNotif)
        
        XCTAssert(
            vc.view!.frame.origin.y == CGFloat(integerLiteral: 0),
            "KeyboardWillShow should shift view")
    }
    
    func testSignUpWithEmail() {
        let handler = MockAuthHandler()
        vc._authHandler = handler
        self.addTeardownBlock { self.vc._authHandler = nil }
        
        let values: [(String?, String?, String?, Int)] = [
            ("Bob", "example@example.com", "", 0),
            ("Bob", "example@example.com", nil, 0),
            ("Bob", "", "myGoodP@ssword1", 0),
            ("Bob", nil, "myGoodP@ssword1", 0),
            ("", "example@example.com", "myGoodP@ssword1", 0),
            (nil, "example@example.com", "myGoodP@ssword1", 0),
            (nil, nil, "myGoodP@ssword1", 0),
            ("", "", "myGoodP@ssword1", 0),
            ("", nil, "myGoodP@ssword1", 0),
            (nil, "", "myGoodP@ssword1", 0),
            ("Bob", "", "", 0),
            ("Bob", nil, nil, 0),
            ("Bob", "", nil, 0),
            ("Bob", nil, "", 0),
            ("", "example@example.com", "", 0),
            (nil, "example@example.com", nil, 0),
            ("", "example@example.com", nil, 0),
            (nil, "example@example.com", "", 0),
            (nil, nil, nil, 0),
            ("", "", "", 0),
            ("Bob", "example@example.com", "myGoodP@ssword1", 1),
        ]
        
        for (name, email, password, nExpectedCalls) in values {
            vc.firstNameField.text = name
            vc.emailField.text = email
            vc.passwordField.text = password
            vc.confirmPassword.text = password
            
            handler.nCallsCreateUser = 0
            
            vc.signUpWithEmail()
            
            XCTAssert(handler.nCallsCreateUser == nExpectedCalls, "Expected: \(nExpectedCalls) Actual: \(handler.nCallsCreateUser) Email: \(email ?? "nil") Name: \(name ?? "nil") Password: \(password ?? "nil")")
        }
    }
    
    func testSignUpWithFacebook() {
        let handler = MockAuthHandler()
        vc._authHandler = handler
        vc.signUpWithFacebook()
        self.addTeardownBlock { self.vc._authHandler = nil }
        
        XCTAssert(handler.nCallsLogInWithFacebook == 1, "Sign up with email should call logInWithFacebook")
    }
}
