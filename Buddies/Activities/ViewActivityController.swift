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
    var stopListeningToActivity: Canceler?
    private var descriptionController: ActivityDescriptionController? = nil
    private var chatController: ActivityChatController? = nil
    
    var users         = [UserId: User]()
    var userImages    = [UserId: UIImage]()
    var userCancelers = [ActivityId: [Canceler]]()
    
    @IBOutlet weak var contentArea: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWith()
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
    
    // Generates the view based on the given activity:
    func loadWith(_ activityId: String = "EgGiWaHiEKWYnaGW6cR3") {
        self.stopListeningToActivity = loadActivity(activityId)
    }
    
    // Loads all of the data needed for the view:
    func loadActivity(uid: String = Auth.auth().currentUser!.uid,
                      _ activityId: String,
                      dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        return dataAccess.useActivity(id: activityId){ activity in
            let status = activity.getMemberStatus(of: uid)
            let topics = self.getTopics(fromIds: activity.topicIds)
            let users = self.getUsers(fromIds: activity.members)
            self.render(for: activity, withStatus: status, withTopics: topics, withUsers: users)
        }
    }

    func getUsers(fromIds userIds: [String]) -> [User] {
        
    }

    func loadUser(uid: UserId,
                  dataAccessor: DataAccessor = DataAccessor.instance,
                  storageManager: StorageManager = StorageManager.shared,
                  onLoaded: (()->Void)?) {
        
        let canceler = dataAccessor.useUser(id: uid) { user in
            self.users[user.uid] = user
            self.loadUserImage(user: user, storageManager: storageManager, onLoaded: onLoaded)
            onLoaded?()
        }
        userCancelers[uid]?.append(canceler)
    }

    func loadUserImage(user: User,
                       storageManager: StorageManager = StorageManager.shared,
                       onLoaded: (()->Void)?) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
        if userImages[user.uid] != nil { return }
        
        storageManager.getImage(
            imageUrl: user.imageUrl,
            localFileName: user.uid) { image in
                self.userImages[user.uid] = image
                onLoaded?()
        }
    }

    func getTopics(fromIds topicIds: [String]) -> [Topic] {
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

    // Renders the activity UI stuff given the data.
    func render(for activity: Activity, withStatus memberStatus: MemberStatus, withTopics topics: [Topic], withUsers users: [User]) {
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
            if(chatController == nil) {
                chatController = ActivityChatController()
                let chatView = UINib(nibName: "ActivityChat", bundle: nil).instantiate(withOwner: chatController, options: nil)[0] as! UIView
                contentArea.addSubview(chatView)
                chatView.bindFrameToSuperviewBounds()
            }
            chatController?.render()
        }
    }
    
    
}
