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


class TopicsVC: UICollectionViewController {

    var topicCollection: TopicCollection!
    
    var selectedTopics = [Topic]()

    
    @IBAction func toggleSelected(_ sender: ToggleButton) {
        guard let cell = sender.superview?.superview?.superview?.superview as? TopicCell,
            let topic = cell.topic else { return }
        changeSelectedState(for: topic, isSelected: sender.isSelected)
    }
    
    func changeSelectedState(for topic: Topic, isSelected: Bool){
        if isSelected {
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopicCell,
            let topic = cell.topic else { return }
        
        cell.toggleButton.toggle()
        let selected = cell.toggleButton.isSelected
        changeSelectedState(for: topic, isSelected: selected)
    }
}

