//
//  MyActivitiesVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase
class MyActivitiesVC: ActivityTableVC, UISearchBarDelegate {
    
    var user: LoggedInUser?
    var cancelUserListener: Canceler?
    var searchTimer: Timer?

    @IBOutlet weak var searchBar: UISearchBar!
    
    // Force is ignored since we don't do the fun Race Condition blocking here
    //  these are your activities and will be fine <3
    override func fetchAndLoadActivities(force: Bool) {
        guard let user = user else { return }
        
        FirestoreManager.getUserAssociatedActivities(userID: user.uid){ activities in
            let filtered = self.filterActivities(activities, query: self.searchBar.text)
            
            self.displayIds = filtered.map { $0.map { $0.activityId } }
            self.loadData(for: self.displayIds)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //Super calls fetchAndLoadActivities
        super.viewWillAppear(animated)
        
        cancelUserListener = DataAccessor.instance.useLoggedInUser{ user in
            guard let user = user else { return }
            let oldUser = self.user
            // If user changed
            self.user = user
            if user.uid != oldUser?.uid {
                self.fetchAndLoadActivities(force: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelUserListener?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        self.setupHideKeyboardOnTap()
    }

    func filterActivities(_ activities: [[Activity]], query: String?) -> [[Activity]] {
        return activities.map { $0.filter { return matchesFilter(activity: $0, query: query) } }
    }
    
    func matchesFilter(activity: Activity, query: String?) -> Bool {
        guard let query = query, !query.isEmpty else { return true }
        
        let lowerQuery = query.lowercased()
        return activity.description.lowercased().contains(lowerQuery)
                || activity.title.lowercased().contains(lowerQuery)
                || activity.locationText.lowercased().contains(lowerQuery)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Create a timer to reload stuff so that we don't just reload for every time a letter is pressed in the search bar
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.fetchAndLoadActivities(force: false)
        }
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

    
}
