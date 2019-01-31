//
//  TopicCollection.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit


class TopicCollection: NSObject {
    var topics = [Topic]() {
        didSet {
            print("TOPICS SET", topics)
        }
    }
    
    func loadSampleTopics() {
        var loadingTopics = [Topic]()
        guard let URL = Bundle.main.url(forResource: "Topics", withExtension: "plist"),
            let photosFromPlist = NSArray(contentsOf: URL) as? [[String:Any]] else {
                topics = []
                return
        }
        for dictionary in photosFromPlist {
            if let topic = Topic(dictionary: dictionary) {
                loadingTopics.append(topic)
            }
        }
        topics = loadingTopics
    }
    
    func loadTopics(){
        FirestoreManager.loadAllDocuments(ofType: "topics") { snapshots in
            for snap in snapshots {
                let data = snap.data()!
                let url = data["image_url"] as! String
                let name = data["name"] as! String
                let dtask = StorageManager.shared.downloadFile(for: url, to: snap.documentID, session: nil) { destURL in
                    OperationQueue.main.addOperation {
                        do {
                            let imageData = try Data(contentsOf: destURL)
                            let image = UIImage(data: imageData)
                            self.topics.append(Topic(name: name, image: image!))
                            print(self.topics)
                        } catch {
                            print("Could not load topic")
                        }
                    }
                }
            }
        }
    }
    
    
    
}
