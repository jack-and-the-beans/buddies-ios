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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func setCornerRadius(to radiusValue: Float) {
//        joinButton.layer.cornerRadius = CGFloat(radiusValue);
//    }

    @IBAction func onReportTap(_ sender: UIBarButtonItem) {
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
    
    // Renders the activity UI stuff:
    func render(for activity: Activity, withStatus memberStatus: MemberStatus) {
        switch memberStatus {
        case .member:
            print("member")
        case .owner:
            print("owner")
        default:
            print("public")
        }
    }
}

// owner (leave / delete / kick user)
// member (leave )
