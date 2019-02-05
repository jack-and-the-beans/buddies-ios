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
    
    
    class StorageNoIO: StorageManager {
        var persistDownloadInvocations = [(source: URL, dest: URL)]()
        override func persistDownload(temp: URL, dest: URL, callback: ((URL) -> Void)?) {
            persistDownloadInvocations.append((source: temp, dest: dest))
        }
        override func localURL(for path: String) -> URL? {
            return URL(string: path)
        }
    }
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStorage() {
        let _ = StorageManager.shared.storage
    }

    func testLocalFilePath() {
        let fileManager = FileManager.default
        let name = "example"
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(name)
            let calculatedURL = StorageManager.shared.localURL(for: name)
            XCTAssert(fileURL == calculatedURL!)
        } catch {
            XCTAssert(false)
        }
    }
    
    
    func testDownload() {
        let session = MockURLSession()
        let manager = StorageNoIO()
        
        let task = manager.downloadFile(for: "testDownloadURL", to: "testDownloadDest", session: session)
        
        XCTAssert((task as! MockURLSessionDownloadTask).started)
        XCTAssert(manager.persistDownloadInvocations.count == 1)
        
        let firstCall = manager.persistDownloadInvocations[0]
        XCTAssert(firstCall.dest.absoluteString == "testDownloadDest")
        XCTAssert(firstCall.source.absoluteString == "mockTempURL")


    }

}
