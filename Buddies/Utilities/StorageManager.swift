//
//  StorageManager.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import FirebaseCore
import FirebaseStorage

class StorageManager {
    
    static var storage: Storage {
        get {
            return Storage.storage()
        }
    }
    
    static func downloadFile(for path: String, to localPath: String, session providedSession: URLSession?,  callback: ((_ path: URL) -> Void)? = nil) -> URLSessionTask? {
        
        let url = URL(string: path)
        
        let session: URLSession = providedSession ?? URLSession(configuration: URLSessionConfiguration.default)
        
        let request = URLRequest(url:url!)
        
        guard let localDestURL = localURL(for: localPath) else {
            return nil
        }

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                StorageManager.persistDownload(temp: tempLocalUrl, dest: localDestURL, callback: callback)
            } else {
                print("Error took place while downloading a file. Error description: \(String(describing: error?.localizedDescription))");
            }
        }
        task.resume()
        
        return task
    }
    
    static func persistDownload(temp: URL, dest: URL, callback: ((_ path: URL) -> Void)?){
        do {
            try FileManager.default.copyItem(at: temp, to: dest)
        } catch (let writeError) {
            print("Error creating a file \(dest.absoluteString) : \(writeError)")
        }
        callback?(dest)
    }
    
    static func localURL(for path: String) -> URL? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            print("Couldn't create directory.")
            return nil
        }
        guard let url = directory.appendingPathComponent(path) else {
            print("Couldn't create file URL.")
            return nil
        }
        
        return url
    }
    
    static func getSavedImage(filename: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let dirUrl = URL(fileURLWithPath: dir.absoluteString)
            let fileUrl = dirUrl.appendingPathComponent(filename).path
            return UIImage(contentsOfFile: fileUrl)
        } else {
            return nil
        }
    }
}
