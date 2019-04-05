//
//  TopicTabVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/21/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth

class TopicTabVC: TopicsVC, TopicCollectionDelegate {
    
    
    var stopListeningToUser: Canceler?
    var user: LoggedInUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topicCollection = appDelegate.topicCollection
        topicCollection.delegate = self

        stopListeningToUser = stopListeningToUser ?? loadProfileData()
    }

    deinit {
        stopListeningToUser?()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? TopicActivityTableVC,
            let indexPath = collectionView.indexPathsForSelectedItems {
            let topic = topicCollection.topics[indexPath[0].row]
            dest.topic = topic
        }
    }
    
    override func changeSelectedState(for topic: Topic, isSelected: Bool){
        super.changeSelectedState(for: topic, isSelected: isSelected)
        user?.favoriteTopics = selectedTopics.map { $0.id }
    }
    

    func updateTopicCollection() {
        collectionView.reloadData()
    }
    
    func loadProfileData(dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        
        return dataAccess.useLoggedInUser { user in
            self.user = user
            
            if let user = user {
                self.selectedTopics = (self.topicCollection.topics).filter { user.favoriteTopics.contains($0.id) }
            } else {
                self.selectedTopics = []
            }
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        return
    }
            
}
