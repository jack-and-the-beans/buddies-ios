//
//  AlgoliaSearch.swift
//  Buddies
//
//  Created by Noah Allen on 2/12/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

/** Usage example:
let search = AlgoliaSearch()
let s = "2019/02/15".toDate()?.date
let e = "2019/02/20".toDate()?.date
search.searchActivities(startingAt: s, endingAt: e, atLocation: (41.1603988, -80.0866907)) { (activities: [String], err: Error?) in
 
    if let error = err { print(error) }
    print(activities)
}
**/

import Foundation
import InstantSearchClient

protocol SearchIndex {
    func search(_ query: Query, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) -> Operation
}
    
extension Index: SearchIndex {}

protocol SearchClient {
    func getIndex(withName indexName: String) -> SearchIndex
}

// Wrap the function so that we can use "SearchIndex" as a mock
extension Client: SearchClient {
    func getIndex(withName indexName: String) -> SearchIndex {
        return index(withName: indexName)
    }
}

class AlgoliaSearch {
    static let ACTIVITY_INDEX = "BUD_ACTIVITIES"
    var client: SearchClient

    init (algoliaClient: SearchClient? = nil) {
        self.client = algoliaClient ?? AlgoliaSearch.algoliaFactory()
    }

    // Constructs an instance of the Algolia Client SDK:
    static func algoliaFactory() -> Client {
        var algoliaAppID = ""
        var algoliaApiKey = ""
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
        return Client(appID: algoliaAppID, apiKey: algoliaApiKey)
    }

    // Searches for Activities with optional params
    func searchActivities(
              withText: String? = nil,
              matchingAnyTopicOf: [String]? = nil,
              startingAt: Date? = nil,
              endingAt: Date? = nil,
              atLocation: (Double, Double)? = nil, // Tuple: (lat, lng)
              upToDistance: Int = 20000, // In meters, defaults to 20km
              aroundPrecision: Int? = nil, // In meters, default to Algolia default
              usingIndex: SearchIndex? = nil,
              sumOrFiltersScores: Bool = true,
              settings: [String: Any]? = nil,
              requestOptions: RequestOptions? = nil,
              
              completionHandler: @escaping ([String], Error?) -> Void) {

        // Initialize activity index if no index is given:
        let index = usingIndex ?? self.client.getIndex(withName: AlgoliaSearch.ACTIVITY_INDEX)
    
        // Use text search if text is given:
        let query = withText != nil ? Query(query: withText) : Query()
        
        // We only need the objectID for activities
        query.attributesToRetrieve = ["objectID"]
        
        // Set location filter if there is a location:
        if let loc = atLocation {
            query.aroundLatLng = LatLng(lat: loc.0, lng: loc.1)
            query.aroundRadius = .explicit(UInt(upToDistance))
            if let aroundPrecision = aroundPrecision { query.aroundPrecision = UInt(aroundPrecision) }
        }
        
        // Get date filter if there are dates:
        var dateFilter: String? = nil
        if let start = startingAt, let end = endingAt {
            dateFilter = self.getDateFilter(fromDate: start, toDate: end)
        }

        // Get topic filter if there are topics:
        let topicFilter = self.getTopicFilterFrom(matchingAnyTopicOf)

        // Conditionally set up filters:
        if let dates = dateFilter, let topics = topicFilter {
            query.filters = "\(dates) AND \(topics)"
        } else if let dates = dateFilter {
            query.filters = dates
        } else if let topics = topicFilter {
            query.filters = topics
        }

        query.sumOrFiltersScores = sumOrFiltersScores
        
        let _ = index.search(query, requestOptions: requestOptions, completionHandler: { (content, error) -> Void in
            if let err = error {
                // Return the error:
                completionHandler([], err); return;
            } else if let res = content?["hits"] as? [[String: AnyObject]] {
                let ids = res.compactMap { $0["objectID"] as? String }
                // Return topic IDs:
                completionHandler(ids, nil); return;
            } else {
                // Return no topics and no IDs:
                completionHandler([], nil); return;
            }
        })
    }
    
    // Note: Any Algolia attribute set up as an array will
    // match the filter as soon as one of the values in the
    // array match. (source: https://www.algolia.com/doc/api-reference/api-parameters/filters/#examples)
    private func getTopicFilterFrom(_ topicIds: [String]?, rank score: Int = 1) -> String? {
        guard let topics = topicIds, topics.count > 0 else { return nil }
        let withQueryKey = topics.map { "topic_ids:\($0)<score=\(score)>" }
        return "(\(withQueryKey.joined(separator: " OR ")))"
    }
    
    // Returns the Algolia Query to match between the two dates.
    private func getDateFilter(fromDate: Date, toDate: Date) -> String {
        let startDate = Int(fromDate.timeIntervalSince1970 * 1000)
        let endDate = Int(toDate.timeIntervalSince1970 * 1000)
        return "(end_time_num >= \(startDate) AND start_time_num <= \(endDate))"
    }
}
