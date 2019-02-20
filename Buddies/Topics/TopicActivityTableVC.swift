//
//  TopicActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

typealias SearchParams = (filterText: String?, when: DateInterval?, maxMetersAway: Int)

class TopicActivityTableVC : ActivityTableVC, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var fab: FAB!
    
    var topicId: String!
    
    // Default is a sentinal because XCode hates nil tuples :(
    var lastSearchParams: SearchParams = ("", nil, 0)
    
    var searchActive = false
    var searchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        self.setupHideKeyboardOnTap()
        
        // We need to store a local so that the
        //  instance isn't deallocated along with
        //  the event handler!
        fab = FAB(for: self)
        fab.renderCreateActivityFab()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(false)
        
        searchTimer?.invalidate()
        fetchAndLoadActivities()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Create a timer to reload stuff so that we don't just call algolia for every time a letter pressed in the search bar
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.fetchAndLoadActivities()
        }
    }
    
    func getSearchParams() -> SearchParams {
        let text = searchBar.text == "" ? nil : searchBar.text
        
        return (text, nil, 20000)
    }
    
    override func fetchAndLoadActivities() {
        let myParams = getSearchParams()
        
        //Cancel if nothing has changed
        if lastSearchParams == myParams { return }
        
        // Store request params #NoRaceConditions
        self.lastSearchParams = myParams
        
        // Load data from algolia!
        search.searchActivities(withText: myParams.filterText,
                                matchingAnyTopicOf: [topicId],
                                startingAt: myParams.when?.start,
                                endingAt: myParams.when?.end,
                                upToDisatnce: myParams.maxMetersAway) {
            (activities: [String], err: Error?) in
            
            // Cancel if we've made a new request #NoRaceConditions
            if self.lastSearchParams != myParams { return }
            
            // Handle errors
            if let error = err { print(error) }
            
            // Load new data
            self.loadData(for: [activities])
        }
    }
}
