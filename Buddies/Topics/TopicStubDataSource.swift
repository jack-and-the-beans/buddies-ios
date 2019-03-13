//
//  TopicStubCollectionVC.swift
//  Buddies
//
//  Created by Luke Meier on 3/11/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class TopicStubDataSource: NSObject, UICollectionViewDataSource {

    var topics = [Topic]()

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
    
    //Not a datasource function, but shared between all collections
    // Leaving the helper here
    func getTopicSize(frameWidth: CGFloat, margin: CGFloat = 20, height: CGFloat = 40) -> CGSize {
        let width = frameWidth - 2*margin
        if (topics.count > 4) {
            let base = width / 2
            return CGSize(width: base, height: height)
        } else {
            let cellWidth = width / 2 - 10
            return CGSize(width: cellWidth, height: height)
        }
    }

}
