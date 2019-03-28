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

    let api = AlgoliaSearch()

    var user: LoggedInUser? { didSet { self.searchBar.sendParams(to: self) } }
    var cancelUserListener: Canceler?
    
    var geoPrecisionGroups = 3.0
    
    override func viewDidLoad() {
        self.setupHideKeyboardOnTap()
        
        cancelUserListener = DataAccessor.instance.useLoggedInUser { user in
            self.user = user
            self.searchBar.provideLoggedInUser(user)
        }
        
        searchBar.displayDelegate = self
                
        super.viewDidLoad()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.closeFilterMenu()
    }
    
    deinit {
        cancelUserListener?()
    }
    
    func getTopics() -> [String] {
        return user?.favoriteTopics ?? []
    }
    
    override func fetchAndLoadActivities() {
        self.startRefreshIndicator()
        let searchParams = searchBar.getSearchParams()
                
        //Sort into `geoPrecisionGroups` number of groups
        //  i.e. for search range of 1000 meters and 4 groups,
        //   the group are [0, 250), [250, 500), [500, 750), [750, 1000+)
        let geoPrecision = Int(Double(searchParams.maxMetersAway)/geoPrecisionGroups)
        
        api.searchActivities(withText: searchParams.filterText,
                             matchingAnyTopicOf: getTopics(),
                             startingAt: searchParams.startDate,
                             endingAt: searchParams.endDate,
                             atLocation: user?.locationCoords,
                             upToDistance: searchParams.maxMetersAway,
                             aroundPrecision: geoPrecision,
                             sumOrFiltersScores: true) {
                                (activities: [ActivityId], err: Error?) in
                                self.updateWantedActivities(with: [activities])                                
        }
    }
}
