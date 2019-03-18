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
            callback?(temp)
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
        XCTAssert(firstCall.source.absoluteString == "testDownloadURL")
    }
    
    class StorageManualSaved : StorageNoIO {
        var savedImage : UIImage?
        override func getSavedImage(filename: String) -> UIImage? {
            return savedImage
        }
    }
    
    func testGetImage_saved() {
        let exp = expectation(description: "image loaded")
        let manager = StorageManualSaved()
        let session = MockURLSession()
        
        // Write a bean
        do {
            let path = Bundle.main.path(forResource: "bean", ofType: "jpg")
            let url = URL(fileURLWithPath: path!)
            let imageData = try Data(contentsOf: url)
            manager.savedImage = UIImage(data: imageData)
        } catch {
            XCTAssertTrue(false, "bean pic not loaded into test manager :(")
            return
        }
        
        manager.getImage(imageUrl: "blah",
                         localFileName: "hello",
                         session: session,
                         callback: { _ in exp.fulfill() })
        
        self.waitForExpectations(timeout: 2.0)
        
        // Should not call persist!
        XCTAssert(manager.persistDownloadInvocations.count == 0)
    }
    
    func testGetImage_nocache() {
        var exp: XCTestExpectation? = expectation(description: "image loaded")
        let manager = StorageManualSaved()
        let session = MockURLSession()

        let path = Bundle.main.path(forResource: "bean", ofType: "jpg")
        let url = URL(fileURLWithPath: path!)

        manager.getImage(imageUrl: url.absoluteString,
                         localFileName: "hello",
                         session: session) { _ in
            exp?.fulfill()
            exp = nil
        }

        self.waitForExpectations(timeout: 2)

        // Should only write once!
        XCTAssert(manager.persistDownloadInvocations.count == 1)
    }
}
