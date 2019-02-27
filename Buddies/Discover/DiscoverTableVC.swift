//
//  DiscoverTableVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class DiscoverTableVC : ActivityTableVC {
    @IBOutlet weak var searchBar: FilterSearchBar!
    
    var user: User? { didSet { self.searchBar.fetchAndLoadActivities() } }
    var cancelUserListener: Canceler?
    
    override func viewDidLoad() {
        self.setupHideKeyboardOnTap()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        cancelUserListener = DataAccessor.instance.useUser(id: userId) { user in
            self.user = user
        }
        
        searchBar.displayDelegate = self
        
        super.viewDidLoad()
    }
    
    deinit {
        cancelUserListener?()
    }
    
    override func getTopics() -> [String] {
        return user?.favoriteTopics ?? []
    }
    
    override func fetchAndLoadActivities() {
        searchBar.fetchAndLoadActivities()
    }
}
