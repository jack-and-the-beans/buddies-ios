//
//  LoginBaseTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class MyActivitiesVCTests: XCTestCase {
    var vc: MyActivitiesVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.Main.viewController(withID: "my-activities")
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
}