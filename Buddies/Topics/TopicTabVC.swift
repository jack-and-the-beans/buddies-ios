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
    
    @IBAction override func toggleSelected(_ sender: ToggleButton) {
        super.toggleSelected(sender)
        user?.favoriteTopics = selectedTopics.map { $0.id }
    }

    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                         dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        
        return dataAccess.useUser(id: uid) { user in
            self.user = user
            if let usr = user {
                self.selectedTopics = (self.topicCollection.topics).filter { usr.favoriteTopics.contains($0.id) }
            } else {
                self.selectedTopics = []
            }
            self.collectionView.reloadData()
        }
    }
}
