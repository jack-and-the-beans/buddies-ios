//
//  Measurements.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class Measurements: XCTestCase {
    
    var viewController: TopicViewController!
    
    override func setUp() {
        viewController = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopicViewController") as! TopicViewController)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUsingTopicLayout() {
        XCTAssertNotNil(viewController.collectionView.collectionViewLayout as? TopicLayout)
    }

    func testValidColumnWidth() {
        if let layout = viewController.collectionView.collectionViewLayout as? TopicLayout {
            assert(layout.columnWidth >= layout.topicElementWidth, "Column width is big enough")
            assert(layout.columnWidth <= layout.topicElementWidth + layout.topicElementWidth * CGFloat(1.0/Double(layout.numberOfColumns)), "Column width could fit another column")
        } else {
            assert(false, "Layout not of TopicLayout type")
        }
    }

}
