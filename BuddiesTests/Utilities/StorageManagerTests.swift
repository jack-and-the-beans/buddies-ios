//
//  StorageManagerTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/1/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class StorageManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStorage() {
        let _ = StorageManager.storage
        XCTAssert(true)
    }

    func testLocalFilePath() {
        let fileManager = FileManager.default
        let name = "example"
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            let calculatedURL = StorageManager.localURL(for: name)
            XCTAssert(fileURL == calculatedURL!)
        } catch {
            XCTAssert(false)
        }
    }

}
