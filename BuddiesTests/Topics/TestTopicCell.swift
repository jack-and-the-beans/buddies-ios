//
//  TopicCell.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class TestTopicCell: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDidSetTopic() {
        let img = UIImage(named: "bean.jpg")
    
        let top = Topic(name: "Example", image: img!)
        let imageView = UIImageView()
        let label = UILabel()
        
        let cell = TopicCell()
        cell.imageView = imageView
        cell.nameLabel = label
        cell.topic = top;
        
        XCTAssert(cell.nameLabel.text == "Example")
        XCTAssert(cell.imageView.image == img)
    }
}
