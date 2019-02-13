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
    
    var storage: Storage {
        get {
            return Storage.storage()
        }
    }
    
    static let shared = StorageManager()
    
    func getImage(imageUrl: String, localFileName: String, session providedSession: URLSession? = nil, callback: @escaping ((UIImage) -> Void)) {
        if let cached = getSavedImage(filename: localFileName) {
            callback(cached)
            return
        }
        
        let _ = downloadFile(for: imageUrl, to: localFileName, session: providedSession) { imageUrl in
            do {
                let imageData = try Data(contentsOf: imageUrl)
                if let image = UIImage(data: imageData) {
                    OperationQueue.main.addOperation {
                        callback(image)
                    }
                } else {
                    print("Failed to downloaded image from \(imageUrl)")
                }
            } catch {
                print("Could not load image from \(imageUrl)\n\n\(error)")
            }
        }
    }
    
    func downloadFile(for path: String, to localPath: String, session providedSession: URLSession?,  callback: ((_ path: URL) -> Void)? = nil) -> URLSessionTask? {
        
        let url = URL(string: path)
        
        let session: URLSession = providedSession
            ?? URLSession(configuration: URLSessionConfiguration.default)
        
        let request = URLRequest(url:url!)
        
        guard let localDestURL = localURL(for: localPath) else {
            return nil
        }

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                self.persistDownload(
                    temp: tempLocalUrl,
                    dest: localDestURL,
                    callback: callback
                )
            } else {
                print("Error took place while downloading a file. Error description: \(String(describing: error?.localizedDescription))");
            }
        }
        task.resume()
        
        return task
    }
    
    func persistDownload(temp: URL, dest: URL, callback: ((_ path: URL) -> Void)? = nil) {
        do {
            try FileManager.default.copyItem(at: temp, to: dest)
        } catch (let writeError) {
            print("Error creating a file \(dest.absoluteString) : \(writeError)")
        }
        callback?(dest)
    }
    
    func localURL(for path: String) -> URL? {
        do {
            let directory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            ) as NSURL
            
            return directory.appendingPathComponent(path)
        } catch { return nil }
    }
    
    func getSavedImage(filename: String) -> UIImage? {
        do {
            let fileURL = localURL(for: filename)
            let imageData = try Data(contentsOf: fileURL!)
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }
}
