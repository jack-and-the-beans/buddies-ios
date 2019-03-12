//
//  TopicStubCollectionVC.swift
//  Buddies
//
//  Created by Luke Meier on 3/11/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

private let reuseIdentifier = "topic_cell"

class TopicStubDataSource: NSObject, UICollectionViewDataSource {

    var topics: [Topic]!

    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Returns the number of topics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }

    // Returns the correct cell for users and topics
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topic_cell", for: indexPath) as! ActivityTopicCollectionCell
        
        let topic = topics[indexPath.row]
        
        cell.render(withTopic: topic)
        return cell
    }
    
    
}
