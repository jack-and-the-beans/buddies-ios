//
//  TopicCollection.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import AVFoundation


class TopicsVC: UICollectionViewController, TopicCollectionDelegate {

    var topicCollection: TopicCollection!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topicCollection = appDelegate.topicCollection
        topicCollection.delegate = self
        
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
                topicCell.topic = topicCollection.topics[indexPath.item]
            }
        
            return cell
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? UITableViewController,
            let indexPath = collectionView.indexPathsForSelectedItems {
            dest.title = topicCollection.topics[indexPath[0].row].name
        }
    }
}

