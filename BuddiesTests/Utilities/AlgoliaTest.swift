//
//  AlgoliaTest.swift
//  BuddiesTests
//
//  Created by Noah Allen on 2/15/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import InstantSearchClient

import XCTest
@testable import Buddies

class AlgoliaTest: XCTestCase {
    func testSearchWithText() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()
        let textQuery = "Mickey Mouse"
        search.searchActivities(withText: textQuery, usingIndex: index) { (ids, err) in
            var checker = false
            XCTAssert(ids.count > 0, "The query completed.")
            if let query = index.query {
                checker = query.query == textQuery
            }
            XCTAssert(checker, "Constructs textual query correctly.")
        }
    }
    func testSearchWithTopics() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()
        let topics = ["a", "b"]
        search.searchActivities(matchingAnyTopicOf: topics, usingIndex: index) { (ids, err) in
            var checker = false
            XCTAssert(ids.count > 0, "The query completed.")
            if let query = index.query {
                let filterText = query.filters
                checker = filterText == "(topic_ids:a OR topic_ids:b)"
            }
            XCTAssert(checker, "Constructs topic query correctly.")
        }
    }
    func testSearchWithDateAndTopics() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()
    
        let start = "2019/02/15".toDate()?.date
        let end = "2019/02/20".toDate()?.date
    
        let topics = ["a", "b"]
        search.searchActivities(matchingAnyTopicOf: topics, startingAt: start, endingAt: end, usingIndex: index) { (ids, err) in
            var checker = false
            XCTAssert(ids.count > 0, "The query completed.")
            if let query = index.query {
                let filterText = query.filters
                let s = Int((start?.timeIntervalSince1970 ?? 20) * 1000)
                let e = Int((end?.timeIntervalSince1970 ?? 20) * 1000)

                checker = filterText == "(end_time_num >= \(s) AND start_time_num <= \(e)) AND (topic_ids:a OR topic_ids:b)"
            }
            XCTAssert(checker, "Constructs topic AND date query correctly.")
        }
    }
    func testSearchWithDate() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()

        let start = "2019/02/15".toDate()?.date
        let end = "2019/02/20".toDate()?.date

        search.searchActivities(startingAt: start, endingAt: end, usingIndex: index) { (ids, err) in
            var checker = false
            XCTAssert(ids.count > 0, "The query completed.")
            if let query = index.query {
                let s = Int((start?.timeIntervalSince1970 ?? 20) * 1000)
                let e = Int((end?.timeIntervalSince1970 ?? 20) * 1000)
                let filterText = query.filters

                checker = filterText == "(end_time_num >= \(s) AND start_time_num <= \(e))"
            }
            XCTAssert(checker, "Constructs topic query correctly.")
        }
    }

    func testSearchWithLocation() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()
        let location = (1.0, 2.0)
        let distance = 10000
        search.searchActivities(atLocation: location, upToDisatnce: distance, usingIndex: index) { (ids, err) in
            var checker = false
            XCTAssert(ids.count > 0, "The query completed.")
            if let query = index.query, let loc = query.aroundLatLng {
                let radius = Int(query.parameters["aroundRadius"] ?? "-1")
                checker = loc.lat == location.0 && loc.lng == location.1 && radius == distance
            }
            XCTAssert(checker, "Constructs location query correctly.")
        }
    }
    
    func testErrrorResult() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        let index = TestIndex()
        let text = "TEST_ERR_CASE"
        search.searchActivities(withText: text, usingIndex: index) { (ids, err) in
            let code = err?._code
            XCTAssert(code != nil, "Returns error case to caller.")
        }
    }
    
    // Test that we do not
    func testAlgoliaFactory() {
        let client = AlgoliaSearch.algoliaFactory()
        XCTAssert(client.apiKey != "NOPE", "Uses the non-default API key.")
        XCTAssert(client.appID != "Uses the non-default app ID")
    }
}
