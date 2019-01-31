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
    
    static let shared = StorageManager()
    
    var storage: Storage {
        get {
            return Storage.storage()
        }
    }
    
    func downloadFile(for path: String, to localPath: String, session providedSession: URLSession?,  callback: ((_ path: URL) -> Void)? = nil) -> URLSessionTask {
        let url = URL(string: path)
        
        let session: URLSession
        if let tempSess = providedSession {
            session = tempSess
        }
        else {
            let sessionConfig = URLSessionConfiguration.default
            session = URLSession(configuration: sessionConfig)
        }
        
        let request = URLRequest(url:url!)
        let localDestURL = localURL(for: localPath)

        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localDestURL!)
                } catch (let writeError) {
                    print("Error creating a file \(localDestURL?.absoluteString ?? "Invalid Filename") : \(writeError)")
                }
                
                if callback != nil {
                    callback!(localDestURL!)
                }
                
            } else {
                print("Error took place while downloading a file. Error description: \(String(describing: error?.localizedDescription))");
            }
        }
        return task

    }
    
    func downloadFile(for firebasePath: String, to localPath: String, onSuccess: ((StorageTaskSnapshot) -> Void)? = nil, onFailure: ((StorageTaskSnapshot) -> Void)? = nil) {
        let itemRef = storage.reference().child(firebasePath)
        
        if let localDestURL = localURL(for: localPath) {
            let downloadTask = itemRef.write(toFile: localDestURL)
            if(onSuccess != nil){
               downloadTask.observe(.success) { snapshot in
                    onSuccess!(snapshot)
                }
            }
            
            if(onFailure != nil){
                downloadTask.observe(.failure) { snapshot in
                    onFailure!(snapshot)
                }
            }
        } else {
            print("Failed to download image")
        }
    }
    
    func localURL(for path: String) -> URL? {
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
    
    func getSavedImage(filename: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let dirUrl = URL(fileURLWithPath: dir.absoluteString)
            let fileUrl = dirUrl.appendingPathComponent(filename).path
            return UIImage(contentsOfFile: fileUrl)
        } else {
            return nil
        }
    }
}
