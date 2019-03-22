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
    func updateTopicCollection() -> Void
}

class TopicCollection: NSObject {
    var topics = [Topic]()
    
    var delegate: TopicCollectionDelegate?
    
    func saveTopic(for id: String, named name: String, image: UIImage?){
        let topic = Topic(id: id, name: name, image: image)
        if let i = topics.firstIndex(where: { $0.id == topic.id } ) {
            topics[i] = topic
        } else {
            //Insert in alphabetically sorted order 
            let i = topics.firstIndex(where: { topic.name < $0.name }) ?? topics.endIndex
            topics.insert(topic, at: i)
        }
        delegate?.updateTopicCollection()
    }
    
    func updateImage(with imageURL: URL, for id: String, uiThread: OperationQueue = OperationQueue.main) {
        do {
            let imageData = try Data(contentsOf: imageURL)
            if let image = UIImage(data: imageData) {
                if let idx = topics.firstIndex(where: {$0.id == id})  {
                    topics[idx].image = image
                    uiThread.addOperation {
                        self.delegate?.updateTopicCollection()
                    }
                }
            } else {
                print("Failed to load downloaded Topic image for \(id)")
            }
        } catch {
            print("Could not load topic, \(error)")
        }
    }
    
    func addTopic(snapshot: DocumentSnapshot, storageManger: StorageManager = StorageManager.shared){
        guard let data = snapshot.data(),
            let name = data["name"] as? String else { return }
        
        if let image = storageManger.getSavedImage(filename: snapshot.documentID) {
            saveTopic(for: snapshot.documentID, named: name, image: image)
        } else {
            saveTopic(for: snapshot.documentID, named: name, image: nil)
            
            guard let firebaseImageURL = data["image_url"] as? String else {
                print("Cannot get Image URL for \(snapshot.documentID)")
                return
            }
            
            let _ = storageManger.downloadFile(
                for: firebaseImageURL,
                to: snapshot.documentID,
                session: nil
            ) { destURL in self.updateImage(with: destURL, for: snapshot.documentID) }
        }
    }
    
    func loadTopics(){
        FirestoreManager.shared.loadAllDocuments(ofType: "topics"){ snapshots in
            for snap in snapshots {
                self.addTopic(snapshot: snap)
            }
        }
    }
    
}
