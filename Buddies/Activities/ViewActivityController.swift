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
    
    // Loads the data needed for the activity:
    func loadActivity(uid: String = Auth.auth().currentUser!.uid,
                      _ activityId: String,
                      dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        return dataAccess.useActivity(id: activityId){ activity in
            let status = activity.getMemberStatus(of: uid)
            self.render(for: activity, withStatus: status)
        }
    }

    // Renders the activity UI stuff. Can be called multiple times.
    func render(for activity: Activity, withStatus memberStatus: MemberStatus) {
        navTitleLabel.title = activity.title
        if (memberStatus == .none) {
            if (descriptionController == nil) {
                descriptionController = ActivityDescriptionController()
                let descriptionView = UINib(nibName: "ActivityDescription", bundle: nil).instantiate(withOwner: descriptionController, options: nil)[0] as! UIView
                contentArea.addSubview(descriptionView)
                descriptionView.bindFrameToSuperviewBounds()
            }
            let topic = Topic(id: "hi", name: "Nature is a cool but big topic", image: nil)
            let topic2 = Topic(id: "2", name: "AAB", image: nil)
            let topic3 = Topic(id: "2", name: "Nature", image: nil)
            let topic4 = Topic(id: "2", name: "Coding Camp", image: nil)
            let topic5 = Topic(id: "2", name: "Smash Bros (tm)", image: nil)
            let topic6 = Topic(id: "2", name: "Abcd", image: nil)
            let topic7 = Topic(id: "2", name: "69", image: nil)

            let user1 = User(name: "NOAH ALLEN")
            let user2 = User(name: "NOAH ALLEN2")
            descriptionController?.render(withActivity: activity, withUsers: [user1, user2], withMemberStatus: memberStatus, withTopics: [topic, topic2, topic3, topic4, topic5, topic6, topic7, topic7])
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

// owner (leave / delete / kick user)
// member (leave )
//
