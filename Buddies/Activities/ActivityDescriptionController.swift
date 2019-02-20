//
//  ActivityDescriptionController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityDescriptionController: UIView, UICollectionViewDataSource {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet weak var topicsArea: UICollectionView!

    @IBOutlet weak var usersArea: UICollectionView!

    var topics: [Topic] = []
    var users: [User] = []

    var memberStatus: MemberStatus = .none

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // Refreshes the UI elements with new data:
    func render(withActivity activity: Activity, withUsers users: [User], withMemberStatus status: MemberStatus, withTopics topics: [Topic] ) {
        registerCollectionViews()
        joinButton?.layer.cornerRadius = 5
        self.locationLabel.text = "Location"
        self.titleLabel.text = activity.title
        self.descriptionLabel.text = activity.description
        self.dateLabel.text = activity.dateCreated.dateValue().calendarString(relativeTo: Date()).capitalized
        self.topics = topics
        self.users = users
        self.memberStatus = status
        self.topicsArea.reloadData()
        self.usersArea.reloadData()
    }
    
    // Returns the number of topics or users for their collections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView === self.topicsArea) {
            return topics.count
        } else {
            return users.count
        }
    }
    
    // Returns the correct cell for users and topics
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView === self.topicsArea) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topic_cell", for: indexPath) as! TopicCollectionCell
            let topic = topics[indexPath.row]
            cell.render(withTopic: topic)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_cell", for: indexPath) as! UserCollectionCell
            cell.render(withUser: users[indexPath.row], shouldRemoveUser: self.memberStatus == .owner)
            return cell
        }
    }
    
    // Registers the nibs and data sources for the users and topics
    func registerCollectionViews () {
        self.topicsArea.dataSource = self
        self.usersArea.dataSource = self
        self.topicsArea.register(UINib.init(nibName: "TopicCollectionCell", bundle: nil), forCellWithReuseIdentifier: "topic_cell")
        self.usersArea.register(UINib.init(nibName: "UserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "user_cell")
    }
}
