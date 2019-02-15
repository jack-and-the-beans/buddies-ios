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

// @TODO: Index
// @TODO: Query
protocol SearchIndex {
    func search(_ query: Query, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) -> Operation
}
extension Index: SearchIndex {}

protocol SearchClient {
    func index(withName indexName: String) -> Index
}

extension Client: SearchClient {}

struct AlgoliaObject {
    var objectID: String
}

class AlgoliaSearch {
    static let ACTIVITY_INDEX = "BUD_ACTIVITIES"
    var client: SearchClient

    init (algoliaClient: SearchClient? = nil) {
        if let client = algoliaClient {
            self.client = client
        } else {
            var algoliaAppID = "NOPE"
            var algoliaApiKey = "NOPE"
            // Grab API key from key file if it exists:
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
            self.client = Client(appID: algoliaAppID, apiKey: algoliaApiKey)
        }
    }

    // Searches for Activities with optional params
    func searchActivities(
              withText: String? = nil,
              topicIds: [String]? = nil,
              startDate: Date?,
              endDate: Date?,
              locationRadius: UInt = 20000, // In meters, defaults to 20km
              location: (Double, Double)?, // Tuple: (lat, lng)
              searchIndex: SearchIndex? = nil,
              completionHandler: @escaping ([String], Error?) -> Void) {

        // Initialize client and activity index:
        let index = searchIndex == nil ? self.client.index(withName: AlgoliaSearch.ACTIVITY_INDEX) : searchIndex!
        
        // Use text search if text is given:
        let query = withText != nil ? Query(query: withText) : Query()
        
        // We only need the objectID for activities
         query.attributesToRetrieve = ["objectID"]
        
        // Set location filter if there is a location:
        if let loc = location {
            query.aroundLatLng = LatLng(lat: loc.0, lng: loc.1)
            query.aroundRadius = .explicit(locationRadius)
        }
        
        // Get date filter if there are dates:
        var dateFilter: String? = nil
        if let start = startDate, let end = endDate {
            dateFilter = self.getDateFilter(fromDate: start, toDate: end)
        }

        // Get topic filter if there are topics:
        let topicFilter = self.getTopicFilterFrom(topicIds)

        // Conditionally set up filters:
        if let dates = dateFilter, let topics = topicFilter {
            query.filters = "\(dates) AND \(topics)"
        } else if let dates = dateFilter {
            query.filters = dates
        } else if let topics = topicFilter {
            query.filters = topics
        }

        let _ = index.search(query, requestOptions: nil, completionHandler: { (content, error) -> Void in
            if let err = error {
                // Return the error:
                completionHandler([], err);
            } else if let res = content?["hits"] as? [[String: AnyObject]] {
                let ids = res.compactMap { $0["objectID"] as? String }
                // Return topic IDs:
                completionHandler(ids, nil)
            } else {
                // Return no topics and no IDs:
                completionHandler([], nil)
            }
        })
    }
    
    // Note: Any Algolia attribute set up as an array will
    // match the filter as soon as one of the values in the
    // array match. (source: https://www.algolia.com/doc/api-reference/api-parameters/filters/#examples)
    private func getTopicFilterFrom(_ topicIds: [String]?) -> String? {
        guard let topics = topicIds else { return nil }
        let withQueryKey = topics.map { "topic_ids:\($0)" }
        return "(\(withQueryKey.joined(separator: " OR ")))"
    }
    
    // Returns the Algolia Query to match between the two dates.
    private func getDateFilter(fromDate: Date, toDate: Date) -> String {
        let startDate = Int(fromDate.timeIntervalSince1970 * 1000)
        let endDate = Int(toDate.timeIntervalSince1970 * 1000)
        return "(end_time_num >= \(startDate) AND start_time_num <= \(endDate))"
    }
}
