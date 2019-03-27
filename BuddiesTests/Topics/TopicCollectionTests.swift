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
    
    
    class MockOperationQueue: OperationQueue {
        var numOperations = 0
        override func addOperation(_ op: Operation) {
            numOperations += 1
        }
    }

    
    class MockCollectionDelegate: TopicCollectionDelegate {
        var fullUpdates = 0
        func updateTopicCollection() {
            fullUpdates += 1
        }
    }
    
    class MockTopicCollection: TopicCollection {
        var saveTopicCalls = 0
        var updateImageCalls = 0
        var loadTopicCalls = 0
        
        override func saveTopic(for id: String, named name: String, image: UIImage?) {
            saveTopicCalls += 1
        }
    
        
        override func updateImage(with imageURL: URL, for id: String, uiThread: OperationQueue) {
            updateImageCalls += 1
        }
        
        override func loadTopics() {
            loadTopicCalls += 1
        }
    }
    
    
    var collection: TopicCollection!
    var delegate: MockCollectionDelegate!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        collection = TopicCollection()
        delegate = MockCollectionDelegate()
        collection.delegate = delegate
        
    }

    func testSaveTopicsSorted(){
        let names = ["x", "b", "e", "h", "u", "aa", "ab", "zz", "xz"]
        let sortedNames = names.sorted { $0 < $1 }
        
        for i in 0..<names.count {
            collection.saveTopic(for: i.description, named: names[i], image: nil)
        }
        
        let collectionNames = collection.topics.map { $0.name }
        
        XCTAssert(collectionNames == sortedNames, "Topic colleciton sorts topics in alphabetical order")
        
    }
   
    
    func testUpdateImage(){
        
        let operationQueue = MockOperationQueue()
        
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
            collection.updateImage(with: url, for: i.description, uiThread: operationQueue)
        }
        
        for i in 0..<7 {
            if i%2 == 0 {
                XCTAssert(collection.topics[i].image != nil)
            } else {
                XCTAssert(collection.topics[i].image == nil)
            }
        }

        //the 0th, 2nd, and 6th item is updated
        XCTAssert(operationQueue.numOperations == 4)
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
        
        XCTAssert(delegate.fullUpdates == 0)
    }
    
    func testAddTopicStorage(){
        let mockCollection = MockTopicCollection()
        
        let data = [
            "name": "test name",
            "image_url": "not SUT",
        ]
        let snap = MockDocumentSnapshot(data: data)
        let storageManager = MockStorageManager()
        //Don't try to fake download
        storageManager.shouldFindSavedImage = true

        mockCollection.addTopic(snapshot: snap, storageManger: storageManager)
        
        XCTAssert(storageManager.downloadFileCalls == 0)
        XCTAssert(storageManager.getSavedImageCalls == 1)
        
        XCTAssert(mockCollection.saveTopicCalls == 1)
        XCTAssert(mockCollection.updateImageCalls == 0)
    }
    
    func testAddTopicDownload(){

        let mockCollection = MockTopicCollection()
        
        let data = [
            "name": "test name",
            "image_url": "not SUT",
            ]
        
        let snap = MockDocumentSnapshot(data: data)
        let storageManager = MockStorageManager()
        
        mockCollection.addTopic(snapshot: snap, storageManger: storageManager)
        
        XCTAssert(storageManager.downloadFileCalls == 1)
        XCTAssert(storageManager.getSavedImageCalls == 1)

        
        XCTAssert(mockCollection.saveTopicCalls == 1)
        XCTAssert(mockCollection.updateImageCalls == 1)
    }
    
    func testInit() {
        // Setup
        let deli = UIApplication.shared.delegate as! AppDelegate
        let mock = MockTopicCollection()
        let oldCollection = deli.topicCollection
        deli.topicCollection = mock
        
        // Call
        AppContent.setup()
        
        // Test
        XCTAssert(mock.loadTopicCalls == 1)
        
        //Tear down
        deli.topicCollection = oldCollection
    }
}
