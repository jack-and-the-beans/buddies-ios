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
    private var descriptionController: ActivityDescriptionController?
    private var chatController: ActivityChatController?
    
    // MARK: Activity specific data which is refreshed by the updater:
    private var curActivity: Activity?
    private var curMemberStatus: MemberStatus?
    private var activityTopics: [Topic]?
    private var activityUsers: [User]?

    private var viewHasMounted = false

    var users         = [UserId: User]()
    var userImages    = [UserId: UIImage]()
    var userCancelers = [ActivityId: [Canceler]]()
    
    @IBOutlet weak var contentArea: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewHasMounted = true
        self.render()
    }

    deinit {
        self.stopListeningToActivity?()
    }

    @IBOutlet weak var navTitleLabel: UINavigationItem!
    
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
            self.activityUsers = self.getUsers(from: activity.members)
            self.activityTopics = self.getTopics(from: activity.topicIds)
            self.curMemberStatus = activity.getMemberStatus(of: uid)
            self.render()
        }
    }

    func getUsers(from userIds: [String]) -> [User] {
        return []
    }

//    func loadUser(uid: UserId,
//                  dataAccessor: DataAccessor = DataAccessor.instance,
//                  storageManager: StorageManager = StorageManager.shared,
//                  onLoaded: (()->Void)?) {
//
//        let canceler = dataAccessor.useUser(id: uid) { user in
//            self.users[user.uid] = user
//            self.loadUserImage(user: user, storageManager: storageManager, onLoaded: onLoaded)
//            onLoaded?()
//        }
//        userCancelers[uid]?.append(canceler)
//    }
//
//    func loadUserImage(user: User,
//                       storageManager: StorageManager = StorageManager.shared,
//                       onLoaded: (()->Void)?) {
//
//        if userImages[user.uid] != nil { return }
//
//        storageManager.getImage(
//            imageUrl: user.imageUrl,
//            localFileName: user.uid) { image in
//                self.userImages[user.uid] = image
//                onLoaded?()
//        }
//    }

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

        navTitleLabel.title = activity.title
        if (memberStatus == .none) {
            if (descriptionController == nil) {
                descriptionController = ActivityDescriptionController()
                let descriptionView = UINib(nibName: "ActivityDescription", bundle: nil).instantiate(withOwner: descriptionController, options: nil)[0] as! UIView
                contentArea.addSubview(descriptionView)
                descriptionView.bindFrameToSuperviewBounds()
            }
            descriptionController?.render(withActivity: activity, withUsers: users, withMemberStatus: memberStatus, withTopics: topics)
        } else {
            // @TODO: remove existing subviews
            if (chatController == nil) {
                chatController = ActivityChatController()
                let chatView = UINib(nibName: "ActivityChat", bundle: nil).instantiate(withOwner: chatController, options: nil)[0] as! UIView
                contentArea.addSubview(chatView)
                chatView.bindFrameToSuperviewBounds()
            }
            chatController?.render()
        }
    }
    
    
}
