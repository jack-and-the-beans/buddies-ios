//
//  TopicStubDataSourceTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 3/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class TopicStubDataSourceTests: XCTestCase {

    var dataSource = TopicStubDataSource()
    var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 500, height: 500), collectionViewLayout: UICollectionViewLayout())
    let numTopics = 20
    
    override func setUp() {
        
        collectionView.register(
            UINib.init(nibName: "ActivityTopicCollectionCell", bundle: nil),
            forCellWithReuseIdentifier: "topic_cell"
        )
        
        dataSource.topics = [Topic](repeating: Topic(id: "id", name: "name", image: nil), count: numTopics)
        collectionView.dataSource = dataSource
    }

    func testGetTopicSize_4plus() {
        let frameWidth: CGFloat = 200
        let margin: CGFloat = 10
        let height: CGFloat = 50
        let size = dataSource.getTopicSize(frameWidth: frameWidth, margin: margin, height: height)
        
        let contentWidth = frameWidth - margin*2
        
        XCTAssert(size.height == height, "Height is set by a parameter")
        
        XCTAssert(size.width == contentWidth/2, "Width is half of content width")
    }
    
    func testGetTopicSize_small() {
        let frameWidth: CGFloat = 200
        let margin: CGFloat = 10
        let height: CGFloat = 50
        
        dataSource.topics = Array(dataSource.topics[0...3])
        
        let size = dataSource.getTopicSize(frameWidth: frameWidth, margin: margin, height: height)
        
        let contentWidth = frameWidth - margin*2
        
        XCTAssert(size.height == height, "Height is set by a parameter")
        
        XCTAssert(size.width == (contentWidth/2 - 10), "Width is half of content width")
    }
    
    func testNumberSections(){
        XCTAssert(dataSource.numberOfSections(in: collectionView) == 1, "There should be only one section in the Topic Stub collection")
    }
    
    func testGetCells(){
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = dataSource.collectionView(collectionView, cellForItemAt: indexPath)
        print(cell)
    }
    
    func testNumberItems(){
        XCTAssert(dataSource.collectionView(collectionView, numberOfItemsInSection: 0) == numTopics, "The collection datasource should have an item for each topic")
    }
}
