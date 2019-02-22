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
    private var stopListeningToActivity: Canceler?
    private var stopListeningToUsers: Canceler?
    private var descriptionController: ActivityDescriptionController?
    private var chatController: ActivityChatController?
    
    // MARK: Activity specific data which is refreshed by the updater:
    private var curActivity: Activity?
    private var curMemberStatus: MemberStatus?
    private var activityTopics: [Topic]?
    private var activityUsers: [User]?

    private var viewHasMounted = false
    
    private var descriptionView: UIView?

    @IBOutlet weak var contentArea: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewHasMounted = true
        self.render()
    }

    deinit {
        self.stopListeningToActivity?()
        self.stopListeningToUsers?()
    }

    
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
    
    func joinActivity() -> Void {
        let uid = Auth.auth().currentUser!.uid
        guard let activity = self.curActivity, let status = self.curMemberStatus else { return }
        if (status == .none) {
            activity.members.append(uid)
        }
    }

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
        
        // Instantiate description view if it does not exist:
        if (descriptionController == nil) {
            descriptionController = ActivityDescriptionController()
            let descView = (UINib(nibName: "ActivityDescription", bundle: nil).instantiate(withOwner: descriptionController, options: nil)[0] as! UIView)
            self.descriptionView = descView
            // Put the view on the superview if the member is public:
            contentArea.addSubview(descView)
        }
        // Render description with updated data:
        descriptionController?.render(withActivity: activity, withUsers: users, withMemberStatus: memberStatus, withTopics: topics, onJoin: self.joinActivity)
        
        if (memberStatus == .none) {
            descriptionController?.expand(animate: false)
        }

        if (memberStatus != .none) {
            if (chatController == nil) {
                chatController = ActivityChatController()
                let chatView = UINib(nibName: "ActivityChat", bundle: nil).instantiate(withOwner: chatController, options: nil)[0] as! UIView

                if let desc = self.descriptionView {
                    contentArea.insertSubview(chatView, belowSubview: desc)
                    descriptionController?.shrink(animate: false)
                } else {
                    contentArea.addSubview(chatView)
                }
                let _ = chatView.bindFrameToSuperviewBounds()
            }
            chatController?.refreshData(with: activity, memberStatus: memberStatus)
        }
    }
}
