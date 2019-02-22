//
//  ActivityDescriptionController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityDescriptionController: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var hasRendered = false

    @IBOutlet var contentView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet weak var topicsArea: UICollectionView!

    @IBOutlet weak var usersArea: UICollectionView!

    @IBAction func onJoinTap(_ sender: Any) {
        self.joinActivity?()
    }

    var topics: [Topic] = []
    var users: [User] = []
    var memberStatus: MemberStatus = .none
    var joinActivity: (() -> Void)?
    var isExpanded: Bool = false
    var curActivity: Activity?

    // Refreshes the UI elements with new data:
    func render(withActivity activity: Activity, withUsers users: [User], withMemberStatus status: MemberStatus, withTopics topics: [Topic], shouldExpand: Bool, onJoin: @escaping () -> Void ) {
        self.curActivity = activity
        registerCollectionViews()
        joinButton?.layer.cornerRadius = 5
        self.locationLabel.text = activity.locationText
        self.titleLabel.text = activity.title
        self.descriptionLabel.text = activity.description
        
        self.dateLabel.text = activity.timeRange.rangePhrase(relativeTo: Date()).capitalized
        self.topics = topics
        self.users = users
        self.joinActivity = onJoin
        self.memberStatus = status
        self.topicsArea.reloadData()
        self.usersArea.reloadData()
        if (shouldExpand) {
            expandMe()
        } else {
            shrinkMe()
        }
        hasRendered = true
    }
    
    // Returns the number of topics or users for their collections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView === self.topicsArea) {
            return topics.count
        } else if (collectionView === self.usersArea){
            return users.count
        } else {
            return 0
        }
    }
    
    // Returns the correct cell for users and topics
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView === self.topicsArea) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topic_cell", for: indexPath) as! ActivityTopicCollectionCell
            let topic = topics[indexPath.row]
            cell.render(withTopic: topic)
            return cell
        } else if (collectionView === self.usersArea){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_cell", for: indexPath) as! ActivityUserCollectionCell
            let user = users[indexPath.row]
            let isIndividualOwner = self.curActivity?.getMemberStatus(of: user.uid) == .owner
            let isCurUserOwner = self.memberStatus == .owner
            cell.render(withUser: users[indexPath.row], isCurUserOwner: isCurUserOwner, isIndividualOwner: isIndividualOwner)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == self.topicsArea) {
            let margin = 20
            let height = CGFloat(40)
            let collectionWidth = self.contentView.frame.width - CGFloat(margin * 2)
            if (self.topics.count > 4) {
                let base = collectionWidth / 2
                return CGSize(width: base, height: height)
            } else {
                let cellWidth = collectionWidth / 2 - 10
                return CGSize(width: cellWidth, height: height)
            }
        } else {
            return CGSize(width: 270, height: 50)
        }
    }

    // Registers the nibs and data sources for the users and topics
    func registerCollectionViews () {
        self.topicsArea.dataSource = self
        self.topicsArea.delegate = self
        self.usersArea.dataSource = self
        self.topicsArea.register(UINib.init(nibName: "ActivityTopicCollectionCell", bundle: nil), forCellWithReuseIdentifier: "topic_cell")
        self.usersArea.register(UINib.init(nibName: "ActivityUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "user_cell")
    }
    
    private var heightConstraint: NSLayoutConstraint?
    func createConstraint(height: CGFloat) {
        if (self.heightConstraint == nil) {
            let hc = NSLayoutConstraint(item: self.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
            self.heightConstraint = hc
            self.contentView.addConstraint(hc)
        } else {
            self.heightConstraint?.constant = height
        }
    }

    func shrinkMe() {
        createConstraint(height: 100)
        performConstraintLayout()
    }
    
    func expandMe() {
        let superview = self.contentView.superview
        let superviewHeight = superview?.frame.height
        createConstraint(height: superviewHeight ?? 400)
        performConstraintLayout()
    }

    // https://stackoverflow.com/a/27417189
    func performConstraintLayout() {
        // We do not want to animate on the first time it loads
        // - e.g. we don't want to animate while the activity is
        // getting displayed modally.
        if hasRendered {
            UIView.animate(withDuration: 1,
                        delay: 0,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 0.6,
                        options: .beginFromCurrentState,
                        animations: { () -> Void in
           self.contentView.superview?.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.contentView.superview?.layoutIfNeeded()
        }
    }

}
