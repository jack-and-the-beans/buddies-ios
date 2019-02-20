//
//  TopicActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation

class TopicActivityTableVC : ActivityTableVC {
    var topicId: String!
    override func fetchAndLoadActivities() {
        search.searchActivities(matchingAnyTopicOf: [topicId]) { (activities: [String], err: Error?) in
            if let error = err { print(error) }
            self.displayIds = [activities]
            self.loadData()
        }
    }
}
