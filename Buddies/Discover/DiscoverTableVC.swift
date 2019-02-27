//
//  DiscoverTableVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        
        lastSearchParam = searchBar.getSearchParams()
        
        super.viewDidLoad()
    }
    
    
    deinit {
        cancelUserListener?()
    }
    
    override func getTopics() -> [String] {
        return user?.favoriteTopics ?? []
    }
    
    override func fetchAndLoadActivities(for params: SearchParams) {
        super.fetchAndLoadActivities(for: params)
        api.searchActivities(withText: params.filterText,
                             matchingAnyTopicOf: getTopics(),
                             startingAt: params.startDate,
                             endingAt: params.endDate,
                             atLocation: user?.locationCoords,
                             upToDistance: params.maxMetersAway) {
                                (activities: [ActivityId], err: Error?) in
                                
                                self.loadAlgoliaResults(activities: activities, from: params, err: err)
                                
        }
    }
}
