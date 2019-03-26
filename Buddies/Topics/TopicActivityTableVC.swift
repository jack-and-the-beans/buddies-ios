//
//  TopicActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

class TopicActivityTableVC : ActivityTableVC {
    @IBOutlet weak var searchBar: FilterSearchBar!
    
    var topic: Topic!
    var user: LoggedInUser?
    var cancelUserListener: Canceler?
    
    @IBOutlet weak var favoriteButton: ToggleButton!
    
    @IBAction func favoriteTopic(_ sender: ToggleButton) {
        if sender.isSelected {
            user?.favoriteTopics.append(topic.id)
        } else {
            if let fav = user?.favoriteTopics {
                user?.favoriteTopics = fav.filter { $0 != self.topic.id }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.closeFilterMenu()
    }
    
    override func viewDidLoad() {
        self.setupHideKeyboardOnTap()
        
        self.title = topic.name
        
        cancelUserListener = DataAccessor.instance.useLoggedInUser { user in
            self.user = user
            self.searchBar.provideLoggedInUser(user)
            
            if let user = user {
                self.favoriteButton.isSelected = user.favoriteTopics.contains(self.topic.id)
            }
        }
        
        searchBar.displayDelegate = self
        
        super.viewDidLoad()
    }
    
    //Manual user testing allows that seems safe to
    //  only cancel listener on deinit
    //  since it only updates a button
    deinit {
        cancelUserListener?()
    }
    
    override func getTopics() -> [String] {
        return [topic.id]
    }
    
    override func fetchAndLoadActivities() {
        let state = searchBar.getFilterState()
        let searchParams = searchBar.getSearchParams(from: state)
        
        api.searchActivities(withText: searchParams.filterText,
                             matchingAnyTopicOf: getTopics(),
                             startingAt: searchParams.startDate,
                             endingAt: searchParams.endDate,
                             atLocation: user?.locationCoords,
                             upToDistance: searchParams.maxMetersAway) {
                                (activities: [ActivityId], err: Error?) in
                                
                                self.loadAlgoliaResults(activities: activities, from: state, err: err)
                                
        }
    }
}
