//
//  DiscoverTableVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import FirebaseAuth
import InstantSearchClient

class DiscoverTableVC : ActivityTableVC {
    @IBOutlet weak var searchBar: FilterSearchBar!
    
    var user: User? { didSet { self.searchBar.sendParams(to: self) } }
    var cancelUserListener: Canceler?
    
    var geoPrecisionGroups = 3.0
    
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
        //Sort into `geoPrecisionGroups` number of groups
        //  i.e. for search range of 1000 meters and 4 groups,
        //   the group are [0, 250), [250, 500), [500, 750), [750, 1000+)
        let geoPrecision = Int(Double(params.maxMetersAway)/geoPrecisionGroups)
        
        api.searchActivities(withText: params.filterText,
                             matchingAnyTopicOf: getTopics(),
                             startingAt: params.startDate,
                             endingAt: params.endDate,
                             atLocation: user?.locationCoords,
                             upToDistance: params.maxMetersAway,
                             aroundPrecision: geoPrecision,
                             sumOrFiltersScores: true) {
                                (activities: [ActivityId], err: Error?) in
                                
                                self.loadAlgoliaResults(activities: activities, from: params, err: err)
                                
        }
    }
}
