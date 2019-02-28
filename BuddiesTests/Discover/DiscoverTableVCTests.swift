//
//  LoginBaseTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class DiscoverTableVCTests: XCTestCase {
    var vc: DiscoverTableVC!
    var algolia: AlgoliaSearch!
    
    override func setUp() {
        vc = DiscoverTableVC()
        let client = TestClient(appID: "appID", apiKey: "apiKey")
        algolia = AlgoliaSearch(algoliaClient: client)
        
        vc.api = algolia
    }
    
    override func tearDown() {
        
    }
    
    func testQueryAlgolia(){
        
    }
    
    func testInitLifecycle() {
        vc = BuddiesStoryboard.Discover.viewController(withID: "viewDiscover")
        UIApplication.setRootView(vc, animated: false)
        vc.api = algolia
        
        _ = vc.view // Make sure view is loaded
        
        XCTAssertNotNil(vc.view, "View should be loaded")
        
        UIApplication.shared.keyWindow?.rootViewController = nil
        vc = nil
    }
}
