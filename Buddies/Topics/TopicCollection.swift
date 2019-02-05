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
    func updateTopicImages() -> Void
}


class TopicCollection: NSObject {
    var topics = [Topic]()
    
    var delegate: TopicCollectionDelegate?
    
    func addFromStorage(using data: [String: Any]?, for id: String, image: UIImage){
        if let topic = Topic(id: id, data: data) {
            topic.image = image
            self.topics.append(topic)
            self.delegate?.updateTopicImages()
        }
    }
    
    func addWithoutImage(using data: [String: Any]?, for id: String){
        if let topic = Topic(id: id, data: data){
            self.topics.append(topic)
            self.delegate?.updateTopicImages()
        }
    }
    
    func updateImage(with imageURL: URL, for id: String){
        do {
            let imageData = try Data(contentsOf: imageURL)
            if let image = UIImage(data: imageData),
                let idx = topics.firstIndex(where: {$0.id == id})  {
                topics[idx].image = image
                self.delegate?.updateTopicImages()
            } else {
                print("Failed to load downloaded Topic image for \(id)")
            }
        } catch {
            print("Could not load topic, \(error)")
        }
    }
    
    func loadTopics(){
        FirestoreManager.shared.loadAllDocuments(ofType: "topics") { snapshots in
            for snap in snapshots {
                if let image = StorageManager.shared.getSavedImage(filename: snap.documentID) {
                    self.addFromStorage(using: snap.data(), for: snap.documentID, image: image)
                } else {
                    self.addWithoutImage(using: snap.data(), for: snap.documentID)
                
                    guard let firebaseImageURL = snap.data()?["image_url"] as? String else {
                        print("Cannot get Image URL for \(snap.documentID)")
                        continue
                    }
                        
                    let _ = StorageManager.shared.downloadFile(
                        for: firebaseImageURL,
                        to: snap.documentID,
                        session: nil
                    ) { destURL in
                        OperationQueue.main.addOperation {
                            self.updateImage(with: destURL, for: snap.documentID)
                        }
                    }
 
                }
                
            }
        }
    }
    
    
    
}
