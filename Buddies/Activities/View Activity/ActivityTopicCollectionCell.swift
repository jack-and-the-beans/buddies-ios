//
//  TopicCollectionCell.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityTopicCollectionCell: UICollectionViewCell {

    @IBOutlet var topicButton: UIButton!
    func render(withTopic topic: Topic) {
        self.topicButton.setTitle(topic.name, for: .normal)
    }
}
