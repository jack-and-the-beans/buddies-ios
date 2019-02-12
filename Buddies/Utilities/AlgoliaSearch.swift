//
//  AlgoliaSearch.swift
//  Buddies
//
//  Created by Noah Allen on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import InstantSearchClient

class AlgoliaSearch {
    
    // Searches for Activities with optional params
    static func searchActivities(text: String? = nil,
                          topicIds: [String]? = nil,
                          startDate: Date,
                          endDate: Date,
                          location: (Double, Double)) {
        
        let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
        let index = client.index(withName: "BUD_ACTIVITIES")
        
        index.search(Query(query: "jimmie"), completionHandler: { (content, error) -> Void in
            if error == nil {
                print("Result: \(content)")
            }
        })
    }
}
