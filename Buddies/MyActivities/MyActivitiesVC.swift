//
//  MyActivitiesVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
class MyActivitiesVC: ActivityTableVC {
    
    var user: LoggedInUser?
    var cancelUserListener: Canceler?
    
    @IBOutlet weak var searchBar: UISearchBar!
    func loadCurUserActivities(userID: String){
        //Get activities current user is associated with
        //2D array of activity IDs
        // [created, joined, previous]
        FirestoreManager.getUserAssociatedActivities(userID: userID){ result in
            self.displayIds = result
            self.loadData(for: self.displayIds)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userId = Auth.auth().currentUser?.uid else { return }
        cancelUserListener = DataAccessor.instance.useLoggedInUser{ user in
            self.user = user
        }
        loadCurUserActivities(userID: userId)
    }
    
    override func viewDidLoad() {
        
        
        self.setupHideKeyboardOnTap()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        cancelUserListener = DataAccessor.instance.useLoggedInUser{ user in
            self.user = user
        }
        
        loadCurUserActivities(userID: userId)
        
        super.viewDidLoad()
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Created"
        case 1:
            return "Joined"
        case 2:
            return "Previous"
        default:
            return nil
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
