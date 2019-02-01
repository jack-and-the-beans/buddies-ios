//
//  NotificationServiceTest.swift
//  BuddiesTests
//
//  Created by Noah Allen on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import XCTest
@testable import Buddies

class NotificationServiceTest: XCTestCase {
    let notificationService = NotificationService()
    let app = XCUIApplication()
    
    override func setUp() {
        app.launch()
    }
    
    func testNotePermissionRequest () {
        addUIInterruptionMonitor(withDescription: "System Dialog") { (alert) -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        NotificationService.registerForNotifications()
        app.tap()
    }
    
    func testTokenSavedOnPermissionGrant () {
        
    }
    
    func testTokenSavedOnTokenUpdate () {
        
    }
    
    func testTokenSave() {
        
    }
}
