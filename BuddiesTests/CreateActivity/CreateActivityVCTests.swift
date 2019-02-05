//
//  LoginBaseTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//
/*
import XCTest
@testable import Buddies

class CreateActivityVCTests: XCTestCase {
    var vc: CreateActivityVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.CreateActivity.viewController(withID: "create")
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: false)
        _ = vc.view // Make sure view is loaded
    }
    
    override func tearDown() {
        UIApplication.shared.keyWindow?.rootViewController = nil
        vc = nil
    }
    
    func testInitLifecycle() {
        XCTAssertNotNil(vc.view, "View should be loaded")
    }
    
    func testBack() {
        let expectation = self.expectation(description: #function)
        vc._dismissHook = {
            expectation.fulfill()
        }
        
        XCTAssertTrue(Testing.getTopViewController() == vc, "Expected create activity view to be shown")
        vc.back(0)
        
        waitForExpectations(timeout: 10)
        XCTAssertFalse(Testing.getTopViewController() == vc, "Expected create activity view to be dismissed")
    }
}

 */
