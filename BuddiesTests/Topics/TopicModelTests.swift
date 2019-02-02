//
//  Topics.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class TestTopicsModel: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testVanillaConstructorUnspecifiedSelected() {
        let img = UIImage()
        let top = Topic(id: "test", name: "Test!", image:img)
        XCTAssert(top.id == "test")
        XCTAssert(top.name == "Test!")
        XCTAssert(top.selected == false)
        XCTAssert(top.image == img)
    }

    func testVanillaConstructorSpecifiedSelected() {
        let img = UIImage()
        let top = Topic(id: "test", name: "Test!", image: img, selected: true)
        XCTAssert(top.id == "test")
        XCTAssert(top.name == "Test!")
        XCTAssert(top.selected == true)
        XCTAssert(top.image == img)
    }
    
    func testTopicFromSnapshot(){
        let data: [String: Any]? = [
            "name": "luke",
            "pie": "no?"
        ]
        if let top = Topic(id: "ID", data: data){
            XCTAssert(top.name == "luke")
            XCTAssert(top.id == "ID")
            XCTAssert(top.image == nil)
            XCTAssert(top.selected == false)
        } else {
            XCTAssert(false)
        }
        
    }
    
    func testTopicFromSnapshotWithNoName(){
        let data: [String: Any]? = [
            "pie": "no?"
        ]
        XCTAssert(Topic(id: "ID", data: data) == nil)
    }

}
