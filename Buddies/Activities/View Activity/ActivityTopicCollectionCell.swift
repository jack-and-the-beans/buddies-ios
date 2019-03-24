//
//  TopicCollectionCell.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityTopicCollectionCell: UICollectionViewCell {

    @IBOutlet weak var topicText: UILabel!
    @IBOutlet weak var topicArea: UIView!
    func render(withTopic topic: Topic) {
        self.layoutIfNeeded()
        self.topicArea.layer.cornerRadius = Theme.cornerRadius
        self.topicArea.layer.masksToBounds = true
        self.topicArea.layer.borderWidth = 1
        self.topicArea.layer.borderColor = Theme.theme.cgColor

        self.topicText.text = topic.name
        self.topicText.textColor = Theme.theme
    }
}
