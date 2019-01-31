//
//  TopicCollection.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol TopicCollectionDelegate {
    func updateTopicImage(index: Int) -> Void
    func updateTopicImages() -> Void
}


class TopicCollection: NSObject {
    var topics = [Topic]()
    
    var delegate: TopicCollectionDelegate?
    
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
    
    func addFromStorage(using snapshot: DocumentSnapshot, image: UIImage){
        if let topic = Topic(snapshot: snapshot) {
            topic.image = image
            self.topics.append(topic)
            self.delegate?.updateTopicImage(index: self.topics.count - 1)
        }
    }
    
    func updateImage(with imageURL: URL, id: String){
        do {
            let imageData = try Data(contentsOf: imageURL)
            if let image = UIImage(data: imageData),
                let idx = topics.firstIndex(where: {$0.id == id})  {
                topics[idx].image = image
                delegate?.updateTopicImage(index: idx)
            } else {
                print("Failed to load downloaded Topic image for \(id)")
            }
        } catch {
            print("Could not load topic")
        }
    }
    
    func loadTopics(){
        FirestoreManager.loadAllDocuments(ofType: "topics") { snapshots in
            for snap in snapshots {
//
                if let image = StorageManager.shared.getSavedImage(filename: snap.documentID) {
                    OperationQueue.main.addOperation {
                        self.addFromStorage(using: snap, image: image)
                        print("Topic loaded from local files")
                    }
                } else {
                    OperationQueue.main.addOperation {
                        print("Topic created without image")
                        self.topics.append(Topic(snapshot: snap)!)
                        self.delegate?.updateTopicImage(index: self.topics.count - 1)
                    }
                    
                    if let firebaseImageURL = snap.data()?["image_url"] as? String {
                        let _ = StorageManager.shared.downloadFile(for: firebaseImageURL, to: snap.documentID, session: nil) { destURL in
                            OperationQueue.main.addOperation {
                                self.updateImage(with: destURL, id: snap.documentID)
                            }
                        }
                    } else {
                        print("Cannot get ImageUrl for \(snap.documentID)")
                    }
                }
                
            }
        }
    }
    
    
    
}
