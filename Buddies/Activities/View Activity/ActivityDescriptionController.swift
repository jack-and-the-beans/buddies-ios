//
//  ActivityDescriptionController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

// Subclass ...ViewDelegate and ...FlowLayout are so
// we can dynamically layout the Topic Collection.
class ActivityDescriptionController: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // Tracks the initial render of the view:
    private var hasRendered = false

    // MARK: UIViews which we use for things:
    @IBOutlet var contentView: UIView!
    @IBOutlet var miniView: UIView!
    @IBOutlet weak var miniContentView: UIView!
    @IBOutlet weak var bigBoyView: UIView!
    
    // MARK: Mini description view outlets:
    @IBOutlet weak var miniLocationLabel: UILabel!
    @IBOutlet weak var miniTimeLabel: UILabel!
    @IBOutlet weak var miniUser3: UIImageView!
    @IBOutlet weak var miniUser2: UIImageView!
    @IBOutlet weak var miniUser1: UIImageView!

    // MARK: Big description view outlets:
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var topicsArea: UICollectionView!
    @IBOutlet weak var usersArea: UICollectionView!

    @IBOutlet weak var shrinkButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Tap on the Join button to call this
    var joinActivity: (() -> Void)? // Set from the parent controller
    @IBAction func onJoinTap(_ sender: Any) {
       joinActivity?()
    }
    
    // Tap the little ^ button to call this
    var toggleBigView: (() -> Void)? // Set from the parent controller
    @IBAction func onShrinkTap(_ sender: Any) {
        toggleBigView?()
    }

    // Tap anywhere in the miniview to call this:
    @objc private func onShowTap(_ sender: UITapGestureRecognizer) {
        toggleBigView?()
    }

    var leaveActivity: (() -> Void)? // Set from the parent controller
    @IBAction func onLeaveTap(_ sender: Any) {
        leaveActivity?()
    }
    
    
    var deleteActivity: (() -> Void)? // Set from parent
    @IBAction func onDeleteTap(_ sender: Any) {
        deleteActivity?()
    }

    var removeUser: ((_ uid: String) -> Void)?
    var tapUser: ((_ uid: String) -> Void)?

    // MARK: Local data sources for rendering:
    var topics: [Topic] = []
    var users: [User] = []
    var memberStatus: MemberStatus = .none
    var curActivity: Activity?
    
    let topicDataSource = TopicStubDataSource()

    override func layoutSubviews() {
        super.layoutSubviews()
        miniUser1.makeCircle()
        miniUser2.makeCircle()
        miniUser3.makeCircle()
    }

    // MARK: Render: Refreshes the UI elements with new data.
    func render(
        withActivity activity: Activity,
        withUsers users: [User],
        withMemberStatus status: MemberStatus,
        withTopics topics: [Topic],
        shouldExpand: Bool,
        onExpand: @escaping () -> Void,
        onLeave: @escaping () -> Void,
        onRemoveUser: @escaping (_ uid: String) -> Void,
        onTapUser: @escaping (_ uid: String) -> Void,
        onDeleteActivity: @escaping () -> Void,
        onJoin: @escaping () -> Void ) {

        // Handle first-time setup:
        if (!hasRendered) {
            self.registerCollectionViews()
            self.initMiniArea()
        }
        
        // Set local data sources & functions to new data:
        self.curActivity = activity
        self.topicDataSource.topics = topics
        self.users = users
        self.joinActivity = onJoin
        self.memberStatus = status
        self.toggleBigView = onExpand
        self.leaveActivity = onLeave
        self.removeUser = onRemoveUser
        self.tapUser = onTapUser
        self.deleteActivity = onDeleteActivity

        // Set UI elements to new data:
        self.locationLabel.text = activity.locationText
        self.miniLocationLabel.text = activity.locationText
        self.titleLabel.text = activity.title
        self.descriptionLabel.text = activity.description
        let dateText = activity.timeRange.rangePhrase(relativeTo: Date()).capitalized
        self.dateLabel.text = dateText
        self.miniTimeLabel.text = dateText
        self.topicsArea.reloadData()
        self.usersArea.reloadData()
        self.configureMiniImages()

        self.deleteButton.tintColor = Theme.bad
        self.leaveButton.tintColor = Theme.bad

        // Conditionally show stuff based on
        // the current user's member status:
        if (memberStatus == .owner) {
            self.leaveButton.isHidden = true
            self.joinButton.isHidden = true
            self.shrinkButton.isHidden = false
            self.deleteButton.isHidden = false
        } else if (memberStatus == .member) {
            self.leaveButton.isHidden = false
            self.joinButton.isHidden = true
            self.shrinkButton.isHidden = false
            self.deleteButton.isHidden = true
        } else {
            // Public case
            self.joinButton.isHidden = false
            self.shrinkButton.isHidden = true
            self.leaveButton.isHidden = true
            self.deleteButton.isHidden = true
        }
        
        // Conditionally handle hiding/showing
        // the expanded description view:
        if (shouldExpand) {
            self.expandMe()
        } else {
            self.shrinkMe()
        }
        
        // Save that the first render has completed:
        self.hasRendered = true
    }
    
    private func initMiniArea () {
        // Setup gesture handler for the mini area:
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onShowTap(_:)))
        miniContentView.isUserInteractionEnabled = true
        miniContentView.addGestureRecognizer(tap)
    }

    private func configureMiniImages () {
        if (users.count > 0) {
            miniUser1.isHidden = false
            miniUser1.image = users[0].image
            miniUser1.makeCircle()
        }
        if (users.count > 1) {
            miniUser2.isHidden = false
            miniUser2.image = users[1].image
            miniUser2.makeCircle()
        }
        if (users.count > 2) {
            miniUser3.isHidden = false
            miniUser3.image = users[2].image
            miniUser3.makeCircle()
        }
        if (users.count < 3) {
            miniUser3.isHidden = true
        }
        if (users.count < 2) {
            miniUser2.isHidden = true
        }
        if (users.count < 1) {
            miniUser1.isHidden = true
        }
    }

    /* ---- MARK: COLLECTION VIEW STUFF ---- */

    // Returns the number of  users for their collections
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView === self.usersArea){
            return users.count
        } else {
            return 0
        }
    }
    
    // Returns the correct cell for users
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView === self.usersArea){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user_cell", for: indexPath) as! ActivityUserCollectionCell
            let user = users[indexPath.row]
            let isIndividualOwner = self.curActivity?.getMemberStatus(of: user.uid) == .owner
            let isCurUserOwner = self.memberStatus == .owner
            cell.render(withUser: users[indexPath.row], isCurUserOwner: isCurUserOwner, isIndividualOwner: isIndividualOwner, tapUser: self.tapUser, removeUser: self.removeUser)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    // Dynamically sizes the topic cells based on the screen size:
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = 20
        let collectionWidth = self.contentView.frame.width - CGFloat(margin * 2)
        if (collectionView == self.topicsArea) {
            return topicDataSource.getTopicSize(frameWidth: contentView.frame.width)
        } else if (collectionView == self.usersArea) {
            return CGSize(width: collectionWidth, height: 50)
        } else {
            // Dummy - should never be called.
            return CGSize(width: 270, height: 50)
        }
    }

    // Registers the nibs and data sources for the users and topics
    private func registerCollectionViews () {
        self.topicsArea.dataSource = topicDataSource
        self.topicsArea.delegate = self
        self.usersArea.dataSource = self
        self.usersArea.delegate = self
        self.topicsArea.register(UINib.init(nibName: "ActivityTopicCollectionCell", bundle: nil), forCellWithReuseIdentifier: "topic_cell")
        self.usersArea.register(UINib.init(nibName: "ActivityUserCollectionCell", bundle: nil), forCellWithReuseIdentifier: "user_cell")
    }

    /* ---- MARK: ANIMATION STUFF ---- */
    
    // Creates a simple height constraint for the given view:
    private func createConstraint(for view: UIView, withHeight height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
    }

    // Handles the height constraint for the large description view:
    private var bigViewHeightConstraint: NSLayoutConstraint?
    private func constrainContaierView(toHeight height: CGFloat) {
        // Create and add it if it doesn't exist
        if (self.bigViewHeightConstraint == nil) {
            let hc = createConstraint(for: self.contentView, withHeight: height)
            self.bigViewHeightConstraint = hc
            self.contentView.addConstraint(hc)
        } else {
            // Otherwise, modify the existing constraint:
            self.bigViewHeightConstraint?.constant = height
        }
    }

    private var miniConstraint: NSLayoutConstraint?
    private func constrainMiniView(toHeight height: CGFloat) {
        // Constrain the view to match the parent top, left, and right sides
        miniView.bindFrameToSuperviewBounds(shouldConstraintBottom: false)
        // Create and add it if it doesn't exist
        if (miniConstraint == nil) {
            let hc = createConstraint(for: miniView, withHeight: height)
            self.miniConstraint = hc
            miniView.addConstraint(hc)
        } else {
            // Otherwise modify the existing constraint
            self.miniConstraint?.constant = height
        }
    }

    // Minimizes the big description and shows the small one:
    private var isExpanded: Bool?
    func shrinkMe() {
        // Only allow user to shrink if it's already expanded:
        if (hasRendered) {
            guard isExpanded == true else { return }
        }
        let smallHeight = CGFloat(80)
        // Display the miniView at the top of the view hierarchy
        self.contentView.insertSubview(miniView, at: 0)
        // Change height constraints to be the small height:
        constrainContaierView(toHeight: smallHeight)
        constrainMiniView(toHeight: smallHeight)
        // Do the animate:
        performAnimation(type: .shrink) { thing in
            self.isExpanded = false
            // After it closes, hide the big description view.
            // Note, its opacity will already be 0, so this should
            // not be a jaring change.
            self.bigBoyView.isHidden = true
            // Need to add the border here because
            // it uses the layout to put itself into
            // place, and the layout changes during
            // the animation.
            self.miniView.addBottomBorderWithColor(color: UIColor.lightGray, thisThicc: 1)
        }
    }

    // Maximizes the big description and hides the small one:
    func expandMe() {
        // Only allow user to expand if it's currently shrunken:
        if (hasRendered) {
            guard isExpanded == false else { return }
        }
        // Remove the miniview and show the big view:
        self.miniView.removeFromSuperview()
        self.bigBoyView.isHidden = false
        self.bigBoyView.alpha = 1
        // Re-constrain the big view to fill the page
        let superview = self.contentView.superview
        let superviewHeight = superview?.frame.height ?? 400 // Should always exist and never hit 400
        constrainContaierView(toHeight: superviewHeight)
        // Do the animiate:
        performAnimation(type: .expand) { thing in
            self.isExpanded = true
        }
    }

    private enum AnimationType {
        case expand
        case shrink
    }

    // Some small info on constraint-based animations: https://stackoverflow.com/a/27417189
    private func performAnimation(type: AnimationType, onComplete: ((Bool) -> Void)?) {
        // We do not want to animate on the first time it loads
        // - e.g. we don't want to animate while the activity is
        // getting displayed modally.
        if hasRendered {
            if type == .shrink {
                // Animate opacity of big view as it
                // hides to reduce a jaring close.
                UIView.animate(withDuration: 0.3) {
                    self.bigBoyView.alpha = 0
                }
            }
            // Springy animation:
            UIView.animate(withDuration: 0.5,
                        delay: 0,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.4,
                        options: .beginFromCurrentState,
                        animations: {
                            // Re-does the layout with new constraints
                            // within the parameters of the animation:
                            self.contentView.superview?.layoutIfNeeded()
            }, completion: onComplete)
        } else {
            // In this case, we don't animate the layout change
            // because the view is displaying modally for the
            // first time.
            self.contentView.superview?.layoutIfNeeded()
            onComplete?(true) // Fake bool because `.animate` completion type requires a bool.
        }
    }

}
