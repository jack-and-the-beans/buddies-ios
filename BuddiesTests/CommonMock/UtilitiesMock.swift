//
//  UtilitiesMock.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/4/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit
@testable import Buddies

class MockURLSessionDownloadTask : URLSessionDownloadTask {
    var started = false
    override func resume() { started = true }
}

class MockURLSession: URLSession {
    var urlString: String? = nil
    override func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        
        urlString = request.url?.absoluteString
        
        completionHandler(URL(string: urlString ?? "mockTempURL"), nil, nil)
        
        return MockURLSessionDownloadTask()
    }
}

class MockStorageManager: StorageManager {
    var downloadFileCalls = 0
    var getSavedImageCalls = 0
    var getImageCalls = 0
    var shouldFindSavedImage = false
    
    
    
    override func downloadFile(for path: String, to localPath: String, session providedSession: URLSession?, callback: ((URL) -> Void)?) -> URLSessionTask? {
        
        downloadFileCalls += 1
        
        let mockURL = URL(string: localPath)!
        
        callback?(mockURL)
        
        return MockURLSessionDownloadTask()
    }
    
    override func getSavedImage(filename: String) -> UIImage? {
        getSavedImageCalls += 1
        if(shouldFindSavedImage){
            return UIImage()
        } else { return nil }
    }
    
    override func getImage(imageUrl: String, localFileName: String, session providedSession: URLSession?, callback: @escaping ((UIImage) -> Void)) {
        getImageCalls += 1
        callback(UIImage())
    }
}

