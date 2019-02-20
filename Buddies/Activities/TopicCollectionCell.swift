//
//  TopicCollectionCell.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class TopicCollectionCell: UICollectionViewCell {

    @IBOutlet var topicButton: UIButton!
    func render(withTopic topic: Topic) {
        self.topicButton.layer.cornerRadius = 5
        self.topicButton.setTitle(topic.name, for: .normal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}