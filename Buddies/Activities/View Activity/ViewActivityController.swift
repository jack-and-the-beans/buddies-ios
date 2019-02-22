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
    private var chatController: ActivityChatController?
    private var descriptionView: UIView?
    @IBOutlet weak var contentArea: UIView! // We render EVERYTHING inside this.

    // MARK: Activity specific data which is refreshed by the updater:
    private var curActivity: Activity?
    private var curMemberStatus: MemberStatus?
    private var activityTopics: [Topic]?
    private var activityUsers: [User]?

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

    // MARK: Actions the user can do in the subviews:
    @IBAction func onBackPress(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func onReportTap(_ sender: Any) {
        let alert = UIAlertController(title: "Report", message: "Why do you want to report this?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Adds the current user to the activity
    // if they are not yet in it.
    func joinActivity() -> Void {
        let uid = Auth.auth().currentUser!.uid
        guard let activity = self.curActivity, let status = self.curMemberStatus else { return }
        if (status == .none) {
            activity.members.append(uid)
        }
    }

    // Local state for toggling the expanded description
    var shouldExpand = false
    func expandDescription() -> Void {
        shouldExpand = !shouldExpand
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
            self.curActivity = activity
            self.getUsers(from: activity.members)
            self.activityTopics = self.getTopics(from: activity.topicIds)
            self.curMemberStatus = activity.getMemberStatus(of: uid)
            self.render()
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
        var neededTopics: [Topic] = []
        let topicsArr = appDelegate.topicCollection.topics
        for topic in topicsArr {
            if (topicIds.contains(topic.id)) {
                neededTopics.append(topic)
            }
        }
        return neededTopics
    }

    func render() {
        // Do not render until view has mounted:
        guard viewHasMounted else { return }

        // Do not render until data exists:
        guard let activity = self.curActivity,
            let memberStatus = self.curMemberStatus,
            let topics = self.activityTopics,
            let users = self.activityUsers else { return }
        
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
            onJoin: self.joinActivity )

        // If (and only if) the user is a member, display the
        // chat area underneath the description:
        if (memberStatus != .none) {
            // Initialize chat area if it's nil:
            if (chatController == nil) {
                chatController = ActivityChatController()
                let chatView = UINib(nibName: "ActivityChat", bundle: nil).instantiate(withOwner: chatController, options: nil)[0] as! UIView

                // Note: the description view should always be initialized
                // before this is called. The else case should never be called.
                // Insert it underneath the description view in the hierarchy.
                if let desc = self.descriptionView {
                    contentArea.insertSubview(chatView, belowSubview: desc)
                } else {
                    contentArea.addSubview(chatView)
                }

                // Bind chat view to parent on all sides
                // so that it takes up the whole screen:
                chatView.bindFrameToSuperviewBounds()
            }
            // Refresh the chat
            chatController?.render(with: activity, memberStatus: memberStatus)
        }
    }
}
