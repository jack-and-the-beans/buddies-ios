//
//  SettingsVCTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/7/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class SettingsVCTests: XCTestCase {
    var vc: SettingsVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.Profile.viewController(withID: "settings")
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
