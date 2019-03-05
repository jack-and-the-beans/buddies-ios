//
//  TopicVCTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 3/5/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class TopicVCTests: XCTestCase {
    
    var topicVC: TopicsVC!
    var topicCollection: TopicCollection!

    override func setUp() {
        
        topicCollection = TopicCollection()
        topicCollection.topics = [
            Topic(id: "id1", name: "fun", image: nil),
            Topic(id: "id2", name: "party", image: nil),
            Topic(id: "id3", name: "dance", image: nil),
            Topic(id: "id4", name: "wooo", image: nil)
        ]
        
        topicVC = TopicsVC()
        
        topicVC.topicCollection = topicCollection
        
        topicVC.selectedTopics = topicCollection.topics
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testChangeSelectedState_RemoveTopic() {
        let initTopics = topicVC.selectedTopics
        
        let removeTopic = Topic(id: "id4", name: "wooo", image: nil)
        
        topicVC.changeSelectedState(for: removeTopic, isSelected: false)
        
        XCTAssert(!topicVC.selectedTopics.contains(where: { $0.id == removeTopic.id }), "Selected topic is no longer in list")
        
        XCTAssert(topicVC.selectedTopics.count == initTopics.count - 1, "One topic is removed to selected set")
    }
    
    func testChangeSelectedState_NewTopic() {
        let initTopics = topicVC.selectedTopics

        let newTopic = Topic(id: "id5", name: "wooo", image: nil)
        
        topicVC.changeSelectedState(for: newTopic, isSelected: true)
        
        
        
        XCTAssert(topicVC.selectedTopics.last!.id == newTopic.id, "Selected topic is now in list")
        
        XCTAssert(topicVC.selectedTopics.count == initTopics.count + 1, "One topic is added to selected set")
    }

}
