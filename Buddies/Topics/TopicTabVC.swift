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

class TopicTabVC: TopicsVC {
    
    var stopListeningToUser: Canceler?
    var user: User?
    
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
            dest.userId = user?.uid
        }
    }
    
    override func changeSelectedState(for topic: Topic, isSelected: Bool){
        super.changeSelectedState(for: topic, isSelected: isSelected)
        user?.favoriteTopics = selectedTopics.map { $0.id }
    }
    

    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                         dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        
        return dataAccess.useUser(id: uid) { user in
            self.user = user
            if let user = user {
                self.selectedTopics = (self.topicCollection.topics).filter { user.favoriteTopics.contains($0.id) }
            } else {
                self.selectedTopics = []
            }
            self.collectionView.reloadData()
        }
    }
}
