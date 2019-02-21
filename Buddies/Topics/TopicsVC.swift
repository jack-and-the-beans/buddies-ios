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

      
    @IBAction func toggleSelected(_ sender: ToggleButton) {
        guard let cell = sender.superview?.superview?.superview as? TopicCell,
            let topic = cell.topic else { return }
    
        if sender.isSelected {
            selectedTopics.append(topic)
        } else {
            selectedTopics = selectedTopics.filter({ $0.id != topic.id })
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
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
        if let dest = segue.destination as? TopicActivityTableVC,
            let indexPath = collectionView.indexPathsForSelectedItems {
            dest.title = topicCollection.topics[indexPath[0].row].name
            dest.topicId = topicCollection.topics[indexPath[0].row].id
        }
    }
    
}

