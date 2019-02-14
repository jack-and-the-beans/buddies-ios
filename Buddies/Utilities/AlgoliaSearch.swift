//
//  AlgoliaSearch.swift
//  Buddies
//
//  Created by Noah Allen on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

//let formatter = DateFormatter()
//formatter.dateFormat = "yyyy/MM/dd"
//let start = formatter.date(from: "2019/02/15")
//let end = formatter.date(from: "2019/02/20") // it comes from here
//
//guard let s = start else { return true }
//guard let e = end else { return true }
//// My Cool Activity
//// start today
//// end march16
//// location: 41.1603988, 80.0866907
//// topics: [JDA0XJW5TVmNEUIUOFJ9, KqfIdTDBRpkwWZkq7kxn, P3blHvOm8DUpN01KOxIp, PYPG1CipYZerw2x5fhvG
//AlgoliaSearch.searchActivities(startDate: s, endDate: e, location: (41.1603988, -80.0866907)) { (activities: [String], err: Error?) in
//    if let error = err { print(error) }
//    print(activities)
//}

import Foundation
import InstantSearchClient

struct AlgoliaObject {
    var objectID: String
}

class AlgoliaSearch {
    // Searches for Activities with optional params
    static func searchActivities(
              withText: String? = nil,
              topicIds: [String]? = nil,
              startDate: Date,
              endDate: Date,
              locationRadius: UInt = 20000, // In meters, defaults to 20km
              location: (Double, Double), // Tuple: (lat, lng)
              completionHandler: @escaping ([String], Error?) -> Void) {

        // Grab API key from key file if it exists:
        var algoliaAppID = "NOPE"
        var algoliaApiKey = "NOPE"
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            if
                let k = keys,
                let apiKey = k["AlgoliaSearchKey"] as? String,
                let appid = k["AlgoliaAppId"] as? String {
                algoliaAppID = appid
                algoliaApiKey = apiKey
            }
        }

        // Initialize client and activity index:
        let client = Client(appID: algoliaAppID, apiKey: algoliaApiKey)
        let index = client.index(withName: "BUD_ACTIVITIES")
        
        // Use text search if text is given:
        let query = withText != nil ? Query(query: withText) : Query()
        
        // We only need the objectID for activities
         query.attributesToRetrieve = ["objectID"]
        
        // Location Filter:
        query.aroundLatLng = LatLng(lat: location.0, lng: location.1)
        query.aroundRadius = .explicit(locationRadius)
        
        // Get filter strings:
        let dateFilter = getDateFilter(fromDate: startDate, toDate: endDate)
        let topicFilter = getTopicFilterFrom(topicIds)
        
        // Only include topic filter if we want:
        query.filters = dateFilter + (topicFilter != nil ? "AND \(topicFilter!)" : "")
        
        index.search(query, completionHandler: { (content, error) -> Void in
            if let err = error {
                completionHandler([], err); return
            }
            guard let res = content?["hits"] as? [[String: AnyObject]] else { completionHandler([], nil); return }

            let ids = res.compactMap { $0["objectID"] as? String }
            
            completionHandler(ids, nil)
        })
    }
    
    // Note: Any Algolia attribute set up as an array will
    // match the filter as soon as one of the values in the
    // array match. (source: https://www.algolia.com/doc/api-reference/api-parameters/filters/#examples)
    private static func getTopicFilterFrom(_ topicIds: [String]?) -> String? {
        guard let topics = topicIds else { return nil }
        let withQueryKey = topics.map { "topic_ids:\($0)" }
        return "(\(withQueryKey.joined(separator: " OR ")))"
    }
    
    // Returns the Algolia Query to match between the two dates.
    private static func getDateFilter(fromDate: Date, toDate: Date) -> String {
        let startDate = Int(fromDate.timeIntervalSince1970 * 1000)
        let endDate = Int(toDate.timeIntervalSince1970 * 1000)
        return "(end_time_num >= \(startDate) AND start_time_num <= \(endDate))"
    }
}
