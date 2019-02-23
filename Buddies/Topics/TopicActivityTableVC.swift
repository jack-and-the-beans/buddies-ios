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
    var mainTopicVC: TopicTabVC!
    @IBOutlet weak var favoriteButton: ToggleButton!
    
    @IBAction func favoriteTopic(_ sender: ToggleButton) {
        mainTopicVC.changeSelectedState(for: topic, isSelected: sender.isSelected)
    }
    
    override func viewDidLoad() {
        self.setupHideKeyboardOnTap()

        searchBar.displayDelegate = self

        super.viewDidLoad()
    }
    
    override func getTopics() -> [String] {
        return [topic.id]
    }
    
    override func fetchAndLoadActivities() {
        searchBar.fetchAndLoadActivities()
    }
}
