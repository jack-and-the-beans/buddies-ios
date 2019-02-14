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
                          locationRadius: UInt = 20000, // In meters, defaults to 20km
                          location: (Double, Double)) { // Tuple: (lat, lng)
        
        let client = Client(appID: "YourApplicationID", apiKey: "YourAPIKey")
        let index = client.index(withName: "BUD_ACTIVITIES")
        
        // Use text search if text is given:
        let query = text != nil ? Query(query: text) : Query()
        
        // We only need the objectID for firebase
        // query.attributesToRetrieve = ["objectID"]
        
        // Location Filter:
        query.aroundLatLng = LatLng(lat: location.0, lng: location.1)
        query.aroundRadius = .explicit(locationRadius)
        
        // Get filter strings:
        let dateFilter = getDateFilter(fromDate: startDate, toDate: endDate)
        let topicFilter = getTopicFilterFrom(topicIds)
        
        // Only include topic filter if we want:
        query.filters = dateFilter + (topicFilter != nil ? "AND \(topicFilter!)" : "")
        
        index.search(query, completionHandler: { (content, error) -> Void in
            if error == nil {
                print("Result: \(content)")
            }
        })
    }
    
    // Note: Any Algolia attribute set up as an array will
    // match the filter as soon as one of the values in the
    // array match. (source: https://www.algolia.com/doc/api-reference/api-parameters/filters/#examples)
    static func getTopicFilterFrom(_ topicIds: [String]?) -> String? {
        guard let topics = topicIds else { return nil }
        let withQueryKey = topics.map { "topic_ids:\($0)" }
        return "(\(withQueryKey.joined(separator: " OR ")))"
    }
    
    // Returns the Algolia Query to match between the two dates.
    static func getDateFilter(fromDate: Date, toDate: Date) -> String {
        let startDate = Int(fromDate.timeIntervalSince1970)
        let endDate = Int(toDate.timeIntervalSince1970)
        return "(\(startDate) >= start_time_num AND \(endDate) <= end_time_num"
    }
}
