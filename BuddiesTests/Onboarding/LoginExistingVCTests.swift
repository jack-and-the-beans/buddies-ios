//
//  LoginBaseTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
import FirebaseFirestore
@testable import Buddies

class LoginExistingVCTests: XCTestCase {
    var vc: LoginExistingVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.Login.viewController(withID: "existing")
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
        
        let values: [(String?, String?, Int)] = [
            ("example@example.com", "", 0),
            ("example@example.com", nil, 0),
            ("", "myGoodP@ssword1", 0),
            (nil, "myGoodP@ssword1", 0),
            ("", "", 0),
            (nil, nil, 0),
            ("", nil, 0),
            (nil, "", 0),
            ("example@example.com", "myGoodP@ssword1", 1),
        ]
        
        for (email, password, nExpectedCalls) in values {
            vc.emailField.text = email
            vc.passwordField.text = password
            
            handler.nCallsLogIn = 0
            
            vc.logIn()
            
            XCTAssert(handler.nCallsLogIn == nExpectedCalls, "Expected: \(nExpectedCalls) Actual: \(handler.nCallsCreateUser) Email: \(email ?? "nil") Password: \(password ?? "nil")")
        }
    }
    
    func testSignUpWithFacebook() {
        let handler = MockAuthHandler()
        vc._authHandler = handler
        self.addTeardownBlock { self.vc._authHandler = nil }
        vc.facebookLogin()
        
        XCTAssert(handler.nCallsLogInWithFacebook == 1, "Sign up with email should call logInWithFacebook")
    }
    
    func testHandleOnLogIn_HasDoc() {
        let uid = MockExistingUser().uid
        let app = MockAD(hasDoc: true)
        
        vc.handleOnLogIn(uid: uid, app: app)
    }
    
    func testHandleOnLogIn_NoDoc() {
        let uid = MockExistingUser().uid
        let app = MockAD(hasDoc: false)
        
        vc.handleOnLogIn(uid: uid, app: app)
    }
    
    func testHandleOnLogIn_nilApp() {
        vc.handleOnLogIn(uid: "hello", app: nil)
    }
    
    class MockAD : AppDelegate {
        let hasDoc: Bool
        init(hasDoc: Bool) { self.hasDoc = hasDoc }
        override func getHasUserDoc(callback: @escaping (Bool) -> Void,
                                    uid: String?,
                                    dataAccess: DataAccessor?,
                                    src: CollectionReference) {
            callback(self.hasDoc)
        }
    }
}
