//
//  Topics.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class Topics: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDictConstructorFull() {
        let dict : [String: Any] = [
            "name": "TestDict",
            "image": "bean.jpg",
            "selected": true
        ]
        if let top = Topic(dictionary: dict) {
            XCTAssert(top.name == "TestDict")
            XCTAssert(top.selected == true)
            XCTAssert(top.image == UIImage(named: "bean.jpg"))
        } else {
            XCTAssert(false, "Could not create Topic")
        }
    }
    
    func testDictConstructorUnspecifiedSelected() {
        let dict = [
            "name": "TestDict",
            "image": "bean.jpg"
        ]
        if let top = Topic(dictionary: dict) {
            XCTAssert(top.name == "TestDict")
            XCTAssert(top.selected == false)
            XCTAssert(top.image == UIImage(named: "bean.jpg"))
        } else {
            XCTAssert(false, "Could not create Topic")
        }
        
    }
    
    func testDictConstructorInvalidDict() {
        let dict = [
            "image": "bean.jpg"
        ]
        if Topic(dictionary: dict) != nil {
            XCTAssert(false, "Should not have created a Topic")
        }
        
    }
    
    
    
    func testVanillaConstructorUnspecifiedSelected() {
        let img = UIImage()
        let top = Topic(name: "Test!", image:img)
        XCTAssert(top.name == "Test!")
        XCTAssert(top.selected == false)
        XCTAssert(top.image == img)
    }

    func testVanillaConstructorSpecifiedSelected() {
        let img = UIImage()
        let top = Topic(name: "Test!", image:img, selected: true)
        XCTAssert(top.name == "Test!")
        XCTAssert(top.selected == true)
        XCTAssert(top.image == img)
    }

    
    func testAllTopics() {
        XCTAssert(Topic.allTopics().count == 13)
    }

}
