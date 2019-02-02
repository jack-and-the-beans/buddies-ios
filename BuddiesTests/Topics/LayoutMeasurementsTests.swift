//
//  Measurements.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class TestLayoutMeasurements: XCTestCase {
    
    var viewController: TopicViewController!
    
    override func setUp() {
        viewController = (UIStoryboard(name: "Topics", bundle: nil).instantiateViewController(withIdentifier: "viewTopics") as! TopicViewController)

        
    }

    override func tearDown() {

        viewController = nil
    }
    
    func testUsingTopicLayout() {
        XCTAssertNotNil(viewController.collectionView.collectionViewLayout as? TopicLayout)
    }

    func testValidColumnWidth() {
        if let layout = viewController.collectionView.collectionViewLayout as? TopicLayout {
            XCTAssert(layout.columnWidth >= layout.topicWidth, "Column width is big enough")
            XCTAssert(layout.columnWidth <= layout.topicElementWidth + layout.topicElementWidth * CGFloat(1.0/Double(layout.numberOfColumns)), "Column width could fit another column")
        } else {
            XCTAssert(false, "Layout not of TopicLayout type")
        }
    }

}
