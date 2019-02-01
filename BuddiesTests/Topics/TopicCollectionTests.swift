//
//  TopicCollectionTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies
import FirebaseFirestore

class TopicCollectionTests: XCTestCase {
    
    class MockCollectioDelegate: TopicCollectionDelegate {
        var fullUpdates = 0
        var specificUpdates = [Int]()
        func updateTopicImages() {
            fullUpdates += 1
        }
        func updateTopicImage(index: Int) {
            specificUpdates.append(index)
        }
    }
    
    var collection: TopicCollection!
    var delegate: MockCollectioDelegate!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        collection = TopicCollection()
        delegate = MockCollectioDelegate()
        collection.delegate = delegate
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddFromStorage(){
        let data: [[String: Any]?] = [
            [
                "name": "luke"
            ],
            nil,
            [
                "name": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addFromStorage(using: data[i], for: i.description, image: UIImage())
        }
        
            
        XCTAssert(collection.topics.count == 2)
        XCTAssert(collection.topics[0].id == "0")
        XCTAssert(collection.topics[0].name == "luke")

        XCTAssert(collection.topics[1].id == "2")
        XCTAssert(collection.topics[1].name == "jake")
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))
    }
    
    func testAddFromStorageInvalid(){
        let data: [[String: Any]?] = [
            [
                "notName": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addFromStorage(using: data[i], for: i.description, image: UIImage())
        }
        
        XCTAssert(collection.topics.count == 0)
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))

    }
    
    func testAddFromStorageMixed(){
        let data: [[String: Any]?] = [
            [
                "notName": "luke"
            ],
            [
                "name": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addFromStorage(using: data[i], for: i.description, image: UIImage())
        }
        
        XCTAssert(collection.topics.count == 1)
        XCTAssert(collection.topics[0].id == "1")
        XCTAssert(collection.topics[0].name == "jake")
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))
    }
    
    
    
    
    func testAddWithoutImage(){
        let data: [[String: Any]?] = [
            [
                "name": "luke"
            ],
            nil,
            [
                "name": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addWithoutImage(using: data[i], for: i.description)
        }
        
        
        XCTAssert(collection.topics.count == 2)
        XCTAssert(collection.topics[0].id == "0")
        XCTAssert(collection.topics[0].name == "luke")
        
        XCTAssert(collection.topics[1].id == "2")
        XCTAssert(collection.topics[1].name == "jake")
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))
        
        
    }
    
    func testAddWithoutImageInvalid(){
        let data: [[String: Any]?] = [
            [
                "notName": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addWithoutImage(using: data[i], for: i.description)
        }
        
        XCTAssert(collection.topics.count == 0)
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))
        
    }
    
    func testAddWithoutImageMixed(){
        let data: [[String: Any]?] = [
            [
                "notName": "luke"
            ],
            [
                "name": "jake"
            ]
        ]
        for i in 0..<data.count {
            collection.addWithoutImage(using: data[i], for: i.description)
        }
        
        XCTAssert(collection.topics.count == 1)
        XCTAssert(collection.topics[0].id == "1")
        XCTAssert(collection.topics[0].name == "jake")
        
        XCTAssert(delegate.fullUpdates == 0)
        let sorted = delegate.specificUpdates.sorted()
        XCTAssert(sorted.elementsEqual(stride(from: 0, to: collection.topics.count, by: 1)))
    }
    
   
    
    func testUpdateImage(){
        
        collection.topics = [
            Topic(id: "0", name: "luke1", image: nil),
            Topic(id: "1", name: "luke2", image: nil),
            Topic(id: "2", name: "luke3", image: nil),
            Topic(id: "3", name: "luke4", image: nil),
            Topic(id: "4", name: "luke5", image: nil),
            Topic(id: "5", name: "luke6", image: nil),
            Topic(id: "6", name: "luke7", image: nil),
        ]
        
        
        let path = Bundle.main.path(forResource: "bean", ofType: "jpg")
        let url = URL(fileURLWithPath: path!)
        
        let elemsUpdated = stride(from: 0, to: 7, by: 2)
        
        for i in elemsUpdated{
            collection.updateImage(with: url, for: i.description)
        }
        
        for i in 0..<7 {
            if i%2 == 0 {
                XCTAssert(collection.topics[i].image != nil)
            } else {
                XCTAssert(collection.topics[i].image == nil)
            }
        }
        XCTAssert(delegate.specificUpdates.elementsEqual(elemsUpdated))
    }
    
    func testUpdateImageNoSuchTopic(){
        
        collection.topics = [
            Topic(id: "0", name: "luke1", image: nil),
            Topic(id: "1", name: "luke2", image: nil),
            Topic(id: "2", name: "luke3", image: nil),
            Topic(id: "3", name: "luke4", image: nil),
            Topic(id: "4", name: "luke5", image: nil),
            Topic(id: "5", name: "luke6", image: nil),
            Topic(id: "6", name: "luke7", image: nil),
        ]
        
        let url = URL(fileURLWithPath: "bean.jpg")
        
        let elemsUpdated = stride(from: 8, to: 15, by: 2)
        
        for i in elemsUpdated{
            collection.updateImage(with: url, for: i.description)
        }
        
        for i in 0..<7 {
            XCTAssert(collection.topics[i].image == nil)
        }
        
        XCTAssert(delegate.specificUpdates.isEmpty)
    }
}