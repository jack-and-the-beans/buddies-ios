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
    
    var user: User? { didSet { self.searchBar.sendParams(to: self) } }
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
    
    override func fetchAndLoadActivities(params: [String:Any]) {
        
        print(params["filterText"] as? String)
        print(params["start"] as? Date)
        print(params["end"] as? Date)
        print(params["distance"] as? Int ?? Int.max)

        
        api.searchActivities(withText: params["filterText"] as? String,
                             matchingAnyTopicOf: getTopics(),
                             startingAt: params["start"] as? Date,
                             endingAt: params["end"] as? Date,
                             upToDisatnce: params["distance"] as? Int ?? Int.max) {
                                (activities: [ActivityId], err: Error?) in
                                
                                // Cancel if we've made a new request #NoRaceConditions
                                //if self.lastSearchParams != myParams { return }
                                
                                // Handle errors
                                if let error = err { print(error) }
                                
                                // Load new data
                                self.loadData(for: [activities])
        }
    }
    
}
