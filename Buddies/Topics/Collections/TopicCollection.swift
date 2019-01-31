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
            let name = dictionary["name"] as! String
            let id = name
            let image = UIImage(named: dictionary["image"] as! String)!
            loadingTopics.append(Topic(id: id, name: name, image: image))
        
        }
        topics = loadingTopics
    }
    
    func loadTopics(){
        FirestoreManager.loadAllDocuments(ofType: "topics") { snapshots in
            for snap in snapshots {
                let data = snap.data()!
                let url = data["image_url"] as! String
                let name = data["name"] as! String
                if let image = StorageManager.shared.getSavedImage(filename: snap.documentID) {
                    OperationQueue.main.addOperation {
                        print("Topic loaded from local files")
                        self.topics.append(Topic(id: snap.documentID, name: name, image: image))
                    }
                } else {
                    OperationQueue.main.addOperation {
                        print("Topic loaded from local files")
                        self.topics.append(Topic(id: snap.documentID, name: name, image: UIImage()))
                    }
                    //If not downloaded yet
                    let dtask = StorageManager.shared.downloadFile(for: url, to: snap.documentID, session: nil) { destURL in
                        OperationQueue.main.addOperation {
                            do {
                                let imageData = try Data(contentsOf: destURL)
                                if let image = UIImage(data: imageData) {
                                    var relatedTopic: Topic? = self.topics.first(where: { topic in
                                        topic.id == snap.documentID
                                    })
                                    relatedTopic?.image = image
                                    print("Updated image")
                                } else {
                                    print("Failed to load downloaded Topic image for \(snap.documentID)")
                                }
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
    
    
    
}
