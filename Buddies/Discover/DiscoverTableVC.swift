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

    var api = AlgoliaSearch()

    var user: LoggedInUser? { didSet { self.searchBar.sendParams(to: self) } }
    var cancelUserListener: Canceler?
    
    var geoPrecisionGroups = 3.0

    
    override func checkAndShowNoActivitiesMessage () {
        let searchParams = searchBar.getSearchParams()
        let hasTextParam: Bool = !(searchParams.filterText?.isEmpty ?? true)

        if (!hasTextParam && dataSource.hasNoActivities() && getTopics().count == 0) {
                tableView.setEmptyMessage("Discover suggests Activities based on your favorite Topics. \n\nVisit the Topics tab to select Topics you love! 😊\n\n\n\n\n\n")
        } else {
           super.checkAndShowNoActivitiesMessage()
        }
    }
    
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
        let hasTextParam: Bool = !(searchParams.filterText?.isEmpty ?? true)
        
        //Hacky way of displaying Onboarding message
        // If topics or search param, do search. Otherwise onboarding msg
        guard hasTextParam || getTopics().count > 0 else {
            self.updateWantedActivities(with: [[]])
            return
        }
        
        let topics = hasTextParam ? [] : getTopics()
        
                
        //Sort into `geoPrecisionGroups` number of groups
        //  i.e. for search range of 1000 meters and 4 groups,
        //   the group are [0, 250), [250, 500), [500, 750), [750, 1000+)
        let geoPrecision = Int(Double(searchParams.maxMetersAway)/geoPrecisionGroups)
        
        api.searchActivities(withText: searchParams.filterText,
                             matchingAnyTopicOf: topics,
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
