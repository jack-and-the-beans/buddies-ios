//
//  TopicActivityTableVCTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/21/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class MockSearchBar : FilterSearchBar {
    var sendCount = 0
    override func sendParams(to target: FilterSearchBarDelegate?) {
        self.sendCount += 1
    }
}

class TopicActivityTableVCTests: XCTestCase {
    var vc: TopicActivityTableVC!
    var mockSearchBar: MockSearchBar!
    
    override func setUp() {
        let topic = Topic(id: "j0FFY5VI4Ti6SZ5jUsDJ", name: "testTopic", image: nil)
        
        vc = BuddiesStoryboard.Topics.viewController(withID: "topicActivitiesTable")
        vc.topic = topic
        
        UIApplication.setRootView(vc, animated: false)
        
        mockSearchBar = MockSearchBar()
        vc.searchBar = mockSearchBar
        _ = vc.view // Make sure view is loaded
    }
    
    override func tearDown() {
        UIApplication.shared.keyWindow?.rootViewController = nil
        vc = nil
    }
    
    func testInitLifecycle() {
        XCTAssertNotNil(vc.view, "View should be loaded")
    }
    
    func testHasTopics() {
        XCTAssert(vc.getTopics().count == 1, "1 topic should be returned!")
    }
}
