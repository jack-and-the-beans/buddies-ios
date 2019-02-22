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
    @IBOutlet var miniView: UIView!
    @IBOutlet weak var miniContentView: UIView!
    @IBOutlet weak var bigBoyView: UIView!
    @IBOutlet weak var miniLocationLabel: UILabel!
    @IBOutlet weak var miniTimeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var shrinkButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!

    @IBOutlet weak var topicsArea: UICollectionView!

    @IBOutlet weak var usersArea: UICollectionView!

    
    @IBOutlet weak var miniUser3: UIImageView!
    @IBOutlet weak var miniUser2: UIImageView!
    @IBOutlet weak var miniUser1: UIImageView!
    
    @IBAction func onJoinTap(_ sender: Any) {
        self.joinActivity?()
    }

    @IBAction func onShrinkTap(_ sender: Any) {
        expandDesc?()
    }

    @objc func onShowTap(_ sender: UITapGestureRecognizer) {
        expandDesc?()
    }

    var topics: [Topic] = []
    var users: [User] = []
    var memberStatus: MemberStatus = .none
    var joinActivity: (() -> Void)?
    var expandDesc: (() -> Void)?
    var isExpanded: Bool = false
    var curActivity: Activity?

    // Refreshes the UI elements with new data:
    func render(withActivity activity: Activity, withUsers users: [User], withMemberStatus status: MemberStatus, withTopics topics: [Topic], shouldExpand: Bool, onExpand: @escaping () -> Void, onJoin: @escaping () -> Void ) {
        // Setup stuff the first time:
        if (!hasRendered) {
            registerCollectionViews()
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onShowTap(_:)))
            miniContentView.isUserInteractionEnabled = true
            miniContentView.addGestureRecognizer(tap)
        }
        self.curActivity = activity
        joinButton?.layer.cornerRadius = 5
        if (memberStatus != .none) {
            joinButton.isHidden = true
            shrinkButton.isHidden = false
        } else {
            joinButton.isHidden = false
            shrinkButton.isHidden = true
        }
        self.locationLabel.text = activity.locationText
        self.miniLocationLabel.text = activity.locationText
        self.titleLabel.text = activity.title
        self.descriptionLabel.text = activity.description
        let dateText = activity.timeRange.rangePhrase(relativeTo: Date()).capitalized
        self.dateLabel.text = dateText
        self.miniTimeLabel.text = dateText
        self.topics = topics
        self.users = users
        self.joinActivity = onJoin
        self.memberStatus = status
        self.topicsArea.reloadData()
        self.usersArea.reloadData()
        self.expandDesc = onExpand
        self.configureMiniImages()
        if (shouldExpand) {
            expandMe()
        } else {
            shrinkMe()
        }
        hasRendered = true
    }
    
    func configureMiniImages () {
        if (users.count > 0) {
            miniUser1.image = users[0].image
            miniUser1.makeCircle()
        }
        if (users.count > 1) {
            miniUser2.image = users[1].image
            miniUser2.makeCircle()
        }
        if (users.count > 2) {
            miniUser3.image = users[2].image
            miniUser3.makeCircle()
        }
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

    func createConstraint(for view: UIView, withHeight height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
    }

    private var heightConstraint: NSLayoutConstraint?
    func constrainContaierView(toHeight height: CGFloat) {
        if (self.heightConstraint == nil) {
            let hc = createConstraint(for: self.contentView, withHeight: height)
            self.heightConstraint = hc
            self.contentView.addConstraint(hc)
        } else {
            self.heightConstraint?.constant = height
        }
    }

    private var miniConstraint: NSLayoutConstraint?
    func constrainMiniView(toHeight height: CGFloat) {
        miniView.bindFrameToSuperviewBounds(shouldConstraintBottom: false)
        if (miniConstraint == nil) {
            miniView.backgroundColor = UIColor.white
            let hc = createConstraint(for: miniView, withHeight: height)
            self.miniConstraint = hc
            miniView.addConstraint(hc)
        } else {
            self.miniConstraint?.constant = height
        }
    }

    func shrinkMe() {
        let smallHeight = CGFloat(80)
        self.contentView.insertSubview(miniView, at: 0)
        constrainContaierView(toHeight: smallHeight)
        constrainMiniView(toHeight: smallHeight)
        if (hasRendered) {
            // Animate opacity of big view as it
            // hides to reduce jaring close.
            UIView.animate(withDuration: 0.3) {
                self.bigBoyView.alpha = 0
            }
        }
        performConstraintLayout() {thing in
            self.bigBoyView.isHidden = true
            self.miniView.addBottomBorderWithColor(color: UIColor.lightGray, thisThicc: 1)
        }
    }

    func expandMe() {
        self.miniView.removeFromSuperview()
        self.bigBoyView.isHidden = false
        self.bigBoyView.alpha = 1
        let superview = self.contentView.superview
        let superviewHeight = superview?.frame.height ?? 400 // Should always exist and never hit 400
        constrainContaierView(toHeight: superviewHeight)
        performConstraintLayout() { thing in }
    }

    // https://stackoverflow.com/a/27417189
    func performConstraintLayout(then: @escaping (Bool) -> Void) {
        // We do not want to animate on the first time it loads
        // - e.g. we don't want to animate while the activity is
        // getting displayed modally.
        if hasRendered {
            UIView.animate(withDuration: 0.5,
                        delay: 0,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.4,
                        options: .beginFromCurrentState,
                        animations: { () -> Void in
           self.contentView.superview?.layoutIfNeeded()
            }, completion: then)
        } else {
            self.contentView.superview?.layoutIfNeeded()
            then(true)
        }
    }

}
