//
//  TopicCollection.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth


class TopicsVC: UICollectionViewController, TopicCollectionDelegate {

    var topicCollection: TopicCollection!
    
    var selectedTopics = [Topic]()
    
    var stopListeningToUser: Canceler?
    var user: User?
  
    @IBAction func toggleSelected(_ sender: ToggleButton) {
        guard let cell = sender.superview?.superview?.superview as? TopicCell,
            let topic = cell.topic else { return }
    
        if sender.isSelected {
            selectedTopics.append(topic)
        } else {
            selectedTopics = selectedTopics.filter({ $0.id != topic.id })
        }
        user?.favoriteTopics = selectedTopics.map { $0.id }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topicCollection = appDelegate.topicCollection
        topicCollection.delegate = self
        
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
    
        stopListeningToUser = stopListeningToUser ?? loadProfileData()
    }
    
    deinit {
        stopListeningToUser?()
    }
    
    func updateTopicImages() {
        collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topicCollection.topics.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "TopicCell",
                for: indexPath
            )
            if let topicCell = cell as? TopicCell {
                let topic = topicCollection.topics[indexPath.item]
                topicCell.topic = topic
                topicCell.toggleButton.isSelected = selectedTopics.contains { $0.id == topic.id }
            }
        
            return cell
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ActivityTableVC,
            let indexPath = collectionView.indexPathsForSelectedItems {
            dest.title = topicCollection.topics[indexPath[0].row].name
        }
    }
    
    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                         dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        
        return dataAccess.useUser(id: uid) { user in
            self.user = user
            self.selectedTopics = (self.topicCollection.topics).filter { user.favoriteTopics.contains($0.id) }
            self.collectionView.reloadData()
        }
    }
    
}

