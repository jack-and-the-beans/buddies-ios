//
//  UIApplicationTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class UIApplicationTests: XCTestCase {
    func testSetRootView() {
        let expectation = self.expectation(description: #function)
        let myVC = BuddiesStoryboard.Login.viewController()
        
        // Set there to be no root view controller
        UIApplication.shared.keyWindow?.rootViewController = nil
        
        UIApplication.setRootView(myVC) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssert(
            UIApplication.shared.keyWindow?.rootViewController != nil,
            "VC should be set as root")
    }
    
    
    func testSetRootViewViaGoto() {
        let expectation = self.expectation(description: #function)
        
        // Set there to be no root view controller
        UIApplication.shared.keyWindow?.rootViewController = nil
        
        BuddiesStoryboard.Login.goTo() {
            expectation.fulfill()
        }
                
        waitForExpectations(timeout: 5)
    }
}
