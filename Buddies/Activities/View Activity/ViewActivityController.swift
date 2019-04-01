//
//  ViewActivityController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewActivityController: UIViewController {
    // Tracks whether or not the view
    // has loaded/mounted yet. (We need
    // to avoid rendering until it has.)
    private var viewHasMounted = false

    // MARK: Listeners
    private var stopListeningToActivity: Canceler?
    private var stopListeningToUsers: Canceler?
    
    // UIViews and controllers:
    private var descriptionController: ActivityDescriptionController?
    private var chatController = ActivityChatController()
    private var descriptionView: UIView?
    @IBOutlet weak var contentArea: UIView! // We render EVERYTHING inside this.

    // MARK: Activity specific data which is refreshed by the updater:
    private var curActivity: Activity?
    private var curMemberStatus: MemberStatus?
    private var activityTopics: [Topic]?
    private var activityUsers: [User]?
    
    var reportButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    
    
    /// Required for the `MessageInputBar` to be visible
    override var canBecomeFirstResponder: Bool {
        
        if curMemberStatus! == .none {
            return false
        }else{
            return chatController.canBecomeFirstResponder
        }
        
 
    }
    
    /// Required for the `MessageInputBar` to be visible
    override var inputAccessoryView: UIView? {
        
        if curMemberStatus! == .none {
            return nil
        }else{
            return chatController.inputAccessoryView
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resignFirstResponder()
    }
    
    
    // Programmatically setup nav bar:
    override func viewDidLoad() {
        self.title = "View Activity"
        //contentArea.becomeFirstResponder()
        reportButton = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(self.onReportTap(_:)))
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.onEditTap))
        reportButton.tintColor = Theme.bad
        
        setupHideKeyboardOnTap()
    }

    // Need to wait to render until here
    // so that the layout is ready to go.
    // Note: viewDidLoad did work for this,
    // but the animations didn't work correctly
    // because the layout didn't have the correct
    // positioning yet.
    override func viewDidLayoutSubviews () {
        viewHasMounted = true
        self.render()
    }
    
    

    deinit {
        self.stopListeningToActivity?()
        self.stopListeningToUsers?()
    }
    
    func goBack () {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func onReportTap(_ sender: Any) {
        guard self.curMemberStatus != .owner else { return }
        showCancelableAlert(withMsg: "What's wrong with this activity?", withTitle: "Report Activity", withAction: "Report", showTextEntry: true) { (didConfirm, msg) in
            guard didConfirm, let activity = self.curActivity else { return }
            FirestoreManager.reportActivity(activity.activityId, reportMessage: msg ?? "")
        }
    }
    
    // Adds the current user to the activity
    // if they are not yet in it.
    func joinActivity() {
        let uid = Auth.auth().currentUser!.uid
        guard let activity = self.curActivity else { return }
        activity.addMember(with: uid)
    }

    func leaveActivity() {
        showCancelableAlert(withMsg: "Are you sure you want to leave this activity?", withTitle: "Leave Activity", withAction: "Leave") { didConfirm, msg in
            guard didConfirm,
                let uid = Auth.auth().currentUser?.uid,
                let status = self.curMemberStatus,
                let activity = self.curActivity,
                status == .member else { return }
            activity.removeMember(with: uid)
            self.goBack()
        }
    }

    func removeUser(uid: String) {
        showCancelableAlert(withMsg: "Are you sure you want to remove this user?", withTitle: "Remove User", withAction: "Remove") { didConfirm, msg in
            guard didConfirm,
                let activity = self.curActivity else { return }
            activity.removeMember(with: uid)
        }
    }
    
    func tapUser(_ uid: String) {
        if let userProfile = BuddiesStoryboard.OtherProfile.viewController(withID: "otherProfile") as? OtherProfileVC {
            userProfile.userId = uid
            self.navigationController?.pushViewController(userProfile, animated: true)
        }
    }

    func deleteActivity() {
        showCancelableAlert(withMsg: "Are you sure you want to delete this activity?", withTitle: "Delete Activity", withAction: "Delete") { didConfirm, msg in
            guard didConfirm,
                let activity = self.curActivity,
                let status = self.curMemberStatus,
                status == .owner else { return }
            FirestoreManager.deleteActivity(activity)
        }
    }
    
    func showCancelableAlert(withMsg msg: String, withTitle title: String, withAction actionMsg: String, showTextEntry: Bool = false, onComplete: @escaping (_: Bool, _ msg: String?) -> Void) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { action in
            onComplete(false, nil)
        })
        alert.addAction(UIAlertAction(title: actionMsg, style: .destructive) { action in
            if let textFields = alert.textFields, textFields.count > 0 {
                let msg = textFields[0].text
                onComplete(true, msg)
            } else {
                onComplete(true, nil)
            }
        })
        if (showTextEntry) {
            alert.addTextField { textField in
                textField.placeholder = "Report details"
            }
        }
        self.present(alert, animated: true, completion: nil)
    }

    // Local state for toggling the expanded description
    var shouldExpand = false
    func expandDescription() {
        shouldExpand = !shouldExpand
        if shouldExpand {
            //resignFirstResponder()
        }else
        {
            //becomeFirstResponder()
        }
        render()
    }

    /* ---- MARK: DATA SET UP ---- */

    // Handles data based on the given activity ID:
    // NOTE WELL: this function gets called during the parent segue prepare,
    // BEFORE viewDidLoad. As a result, the actual view elements may not
    // be mounted in time for this function (or others) to use them.
    func loadWith(
        _ activityId: ActivityId?,
        dataAccess: DataAccessor = DataAccessor.instance,
        currentUser uid: String = Auth.auth().currentUser!.uid
        ) {
        guard let id = activityId else { return }

        self.stopListeningToActivity = dataAccess.useActivity(id: id) { activity in
            if let activity = activity {
                self.curActivity = activity
                self.getUsers(from: activity.members)
                self.activityTopics = self.getTopics(from: activity.topicIds)
                self.curMemberStatus = activity.getMemberStatus(of: uid)
                self.render()
            } else {
                // It has been deleted
                self.stopListeningToActivity?()
                self.goBack()
            }
        }
    }

    // Gets user info based on the activity's members:
    func getUsers(from newUserIds: [String]) {
        let existingIds = self.activityUsers?.map { $0.uid }
        let usersHaveChanged = existingIds?.sorted() != newUserIds.sorted()

        // If there are different users from the activity,
        // stop listening to the existing users and create
        // a new listener with the changed user ids.
        if (usersHaveChanged) {
            self.stopListeningToUsers?()
            self.stopListeningToUsers = DataAccessor.instance.useUsers(from: newUserIds) { users in
                // re-render when the users change:
                self.activityUsers = users
                self.render()
            }
        }
    }

    // Gets topics from the root topic store:
    func getTopics(from topicIds: [String]) -> [Topic] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let topics = appDelegate.topicCollection.topics.filter { topicIds.contains($0.id) }
        return topics
    }
    
    @objc func onEditTap() {
        if let vc = BuddiesStoryboard.CreateActivity.viewController() as? UINavigationController,
           let editView = vc.topViewController as? CreateActivityVC {
            editView.activity = curActivity
            present(vc, animated: true)
        }
    }

    func render() {
        // Do not render until view has mounted:
        guard viewHasMounted else { return }

        // Do not render until data exists:
        guard let activity = self.curActivity,
            let memberStatus = self.curMemberStatus,
            let topics = self.activityTopics else { return }

        let users = self.activityUsers ?? []

        // We always load the description view because it is for all member statuses:
        // Instantiate description view if it does not exist:
        if (descriptionController == nil) {
            descriptionController = ActivityDescriptionController()
            let descView = (UINib(nibName: "ActivityDescription", bundle: nil).instantiate(withOwner: descriptionController, options: nil)[0] as! UIView)
            self.descriptionView = descView
            // Put the view on the superview if the member is public:
            contentArea.addSubview(descView)

            // Bind description view to all sides except the bottom, so that we can animate it.
            descView.bindFrameToSuperviewBounds(shouldConstraintBottom: false)
        }
    
        // Render description with updated data:
        let shouldExpand = memberStatus == .none || self.shouldExpand // Always stay expanded if the user is not a member.
        descriptionController?.render(
            withActivity: activity,
            withUsers: users,
            withMemberStatus: memberStatus,
            withTopics: topics,
            shouldExpand: shouldExpand,
            onExpand: self.expandDescription,
            onLeave: self.leaveActivity,
            onRemoveUser: self.removeUser,
            onTapUser: self.tapUser,
            onDeleteActivity: self.deleteActivity,
            onJoin: self.joinActivity )
        
        
        // If (and only if) the user is a member, display the
        // chat area underneath the description:
        if (memberStatus != .none) {
            
            if !shouldExpand{
                // Note: the description view should always be initialized
                // before this is called. The else case should never be called.
                // Insert it underneath the description view in the hierarchy.
                if let desc = self.descriptionView {
                    contentArea.insertSubview((chatController.view)!, belowSubview: desc)
                    self.addChild(chatController)
                    chatController.didMove(toParent: self)
                    chatController.activity = activity
                    
                    chatController.loadMessageList()
                    
                    //contentArea.insertSubview(chatController.messageInputBar, belowSubview: desc)
                    becomeFirstResponder()
                    //adjust height
                    chatController.view.frame = CGRect(x: 0, y: descriptionView!.frame.height, width: view.bounds.width, height: view.bounds.height - descriptionView!.frame.height)
                    chatController.view.bindFrameToSuperviewBounds()
                }
            }
            else
            {
                resignFirstResponder()  
                chatController.view.removeFromSuperview()
                chatController.messageInputBar.removeFromSuperview()
            }
           
        }
        
        // Don't allow the owner to report an activity:
        navigationItem.rightBarButtonItem = memberStatus == .owner
            ? editButton
            : reportButton
    }
}
