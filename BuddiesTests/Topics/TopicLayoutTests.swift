//
//  TopicLayoutTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 3/4/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//


import XCTest
@testable import Buddies

class TopicLayoutTests: XCTestCase {

    var layout: TopicLayout!
    var collectionView: UICollectionView!
    
    override func setUp() {
        
        layout = TopicLayout()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func setupCollectionView() -> UICollectionView {
        let frame = CGRect(x: 0, y: 0, width: 828, height: 1700)
        
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        return collectionView
    }
    
    func getDataSource() -> TopicsVC {
        let vc = TopicsVC()
        vc.topicCollection = TopicCollection()
        return vc
    }
    
    func testVCDimensions (){
        let numTopics = 100
        
        let collectionView = setupCollectionView()
        
        let vc = getDataSource()
        
        collectionView.dataSource = vc
            
        vc.topicCollection.topics = [Topic](repeating:  Topic(id: "test", name: "hey", image: nil), count: numTopics)
        
        collectionView.reloadData()
        
        layout.prepare()
        
        XCTAssert(layout.cache.count == vc.topicCollection.topics.count, "Cache atttribute created for each Topic")
    }
    

    func testXOffsets() {
        let numCols = 10
        let size: CGFloat = 100.0
        let offsets = layout.xOffsets(for: numCols, ofSize: size)
        var i: CGFloat = -1
        let allCorrect = offsets.allSatisfy { i += 1; return $0 == i*size}
        XCTAssert(allCorrect, "xOffsets increment by width size")
    }
    
    func testYOffsets() {
        let numRows = 10
        let size: CGFloat = 100.0
        let offsets = layout.yOffsets(for: numRows, ofSize: size)
        var i: CGFloat = -1
        let allCorrect = offsets.allSatisfy { i += 1; return $0 == i*size}
        XCTAssert(allCorrect, "yOffsets increment by width size")
    }

    
    func testCellHeight(){
        let width: CGFloat = 100
        let ratio: CGFloat = 0.5
        let padding: CGFloat = 5.0
        
        let actualValue = width * ratio + 2 * padding
        
        let calcValue = layout.cellHeight(relativeTo: width, ratio: ratio, padding: padding)
    
        XCTAssert(calcValue == actualValue, "cellHeight calculated correctly")
    }


    func testFrameFor(){
        let (xOffset, yOffset): (CGFloat, CGFloat) = (10.0, 5.0)
        let (width, height): (CGFloat, CGFloat) = (100, 50)
        
        let padding: CGFloat = 3.0
        
        let frame = layout.frameFor(xOffset: xOffset, yOffset: yOffset, width: width, height: height, padding: padding)
        
        XCTAssert(frame.width == width-2*padding, "Width is set correctly")
        XCTAssert(frame.height == height-2*padding, "Width is set correctly")
        XCTAssert(frame.minX == xOffset+padding, "Inset xOffset is correct")
        XCTAssert(frame.minY == yOffset+padding, "Inset yOffset is correct")



    }
    
    func testCacheCell(){
        let width: CGFloat = 100
        let height: CGFloat = 150
        
        let xOffset: CGFloat = 10
        let yOffset: CGFloat = 15
        let indexPath = IndexPath(item: 10, section: 0)
        let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        
        XCTAssert(layout.cache.count == 0, "Layout cache initially is empty")
        
        layout.cacheCell(at: indexPath, frame: frame)
        
        XCTAssert(layout.cache.count == 1, "Layout cache has one element after adding")
        
        let v = layout.cache[0]
        
        XCTAssert(v.bounds.width == width, "Width is cached correctly")
        XCTAssert(v.bounds.height == height, "Height is cached correctly")
        XCTAssert(v.indexPath == indexPath, "IndexPath is cached correctly")
    }
    
    func testLayoutAttributesForElements(){
        let someIdxPath = IndexPath(item: 0, section: 0)
        let bigFrame = CGRect(x: 10, y: 10, width: 100, height: 100)
        let nonIntersectFrame = CGRect(x: 0, y: 0, width: 5, height: 5)
        
        layout.cacheCell(at: someIdxPath, frame: bigFrame)
        layout.cacheCell(at: someIdxPath, frame: nonIntersectFrame)
        
        let matching = layout.layoutAttributesForElements(in: CGRect(x: 50, y: 50, width: 10, height: 10))
        
        XCTAssert(matching?.count == 1, "Only one of the rectangles intersect")

    }
    
    
    
    func testLayoutAttributesForItem(){
        let indexPath = IndexPath(item: 0, section: 0)
        
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        layout.cache.append(attr)
        
        let retrAttr = layout.layoutAttributesForItem(at: indexPath)
        
        XCTAssert(attr === retrAttr, "Attribute is loaded correctly from cache")
    }

    
    func testEmptyPrepare(){
        layout.prepare()
        XCTAssert(layout.cache.count == 0, "Nothing should be added to cache")
    }
    
    func testShouldInvalidateLayout_NoCollectionView(){
        let shouldInvalidate = layout.shouldInvalidateLayout(forBoundsChange: CGRect())
        XCTAssertFalse(shouldInvalidate, "When no collectionview, never invalidate")
    }
    
    func testShouldInvalidateLayout_CollectionView(){
        let initRect = CGRect(x: 10, y: 10, width: 100, height: 100)
        //Can't set it to _, otherwise test fails
        let collectionView = UICollectionView(frame: initRect, collectionViewLayout: layout)
        
        let newRect = CGRect(x: 10, y: 10, width: 110, height: 100)
        
        let newBounds = layout.shouldInvalidateLayout(forBoundsChange: newRect)
        XCTAssert(newBounds, "When  collectionview, invalidate if bounds")
        
        let sameBounds = layout.shouldInvalidateLayout(forBoundsChange: initRect)
        XCTAssert(!sameBounds, "When  collectionview, invalidate if bounds")
        
        //to get rid of compiler warning
        collectionView.backgroundView = nil
    }

}
