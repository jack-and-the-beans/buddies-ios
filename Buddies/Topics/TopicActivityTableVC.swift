//
//  TopicActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

class TopicActivityTableVC : ActivityTableVC, SearchHandlerDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    var fab: FAB!
    var searchHandler: SearchHandler!
    
    var topicId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupHideKeyboardOnTap()
        
        // We need to store a local so that the
        //  instance isn't deallocated along with
        //  the event handler!
        fab = FAB(for: self)
        fab.renderCreateActivityFab()
        
        searchHandler = SearchHandler(for: searchBar, delegate: self, api: AlgoliaSearch())
    }
    
    func endEditing() {
        self.view.endEditing(false)
    }
    
    func display(activities: [ActivityId]) {
        self.loadData(for: [activities])
    }
    
    func getTopics() -> [String] {
        return [topicId]
    }
    
    override func fetchAndLoadActivities() {
        searchHandler.fetchAndLoadActivities()
    }
}
