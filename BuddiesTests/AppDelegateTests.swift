//
//  AppDelegateTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/7/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies
import Firebase
import FirebaseFirestore

class AppDelegateTests: XCTestCase {
    func testDelType() {
        XCTAssertNotNil(UIApplication.shared.delegate as? AppDelegate)
    }
    
    func testSetupApp_LoggedInWithDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupView(isLoggedOut: true,
                      isInitial: true,
                      needsAccountInfo: false)
    }
    
    func testSetupApp_LoggedOutWithDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupView(isLoggedOut: true, isInitial: true, needsAccountInfo: false)
    }
    
    func testSetupApp_LoggedInNoDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupView(isLoggedOut: false, isInitial: true, needsAccountInfo: true)
    }
    
    func testSetupApp_LoggedOutNoDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupView(isLoggedOut: true, isInitial: true, needsAccountInfo: true)
    }
    
    func testHandleLaunch() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }

        let info = ActivityNotificationInfo(activityId: "abcd", navigationDestination: "discover")
        app.pendingNotificationToLoad = info
        app.handleLaunchFromNotification()
    }
}
