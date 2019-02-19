//
//  AlgoliaMock.swift
//  BuddiesTests
//
//  Created by Noah Allen on 2/15/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
@testable import Buddies
import InstantSearchClient

class TestClient: SearchClient {
    var appID: String = ""
    var apiKey: String = ""
    // Add index to the client so we can observe it:
    var index: SearchIndex? = nil

    func getIndex(withName indexName: String) -> SearchIndex {
        self.index = TestIndex()
        return self.index!
    }
    
    init(appID: String, apiKey: String){
        self.appID = appID
        self.apiKey = apiKey
    }
}

class TestIndex: SearchIndex {
    var query: Query? = nil
    let result = [
        "hits": [
            [
                "objectID": "1"
            ],
            [
                "objectID": "2"
            ],
            [
                "objectID": "3"
            ]
        ]
    ]

    func search(_ query: Query, requestOptions: RequestOptions?, completionHandler: @escaping CompletionHandler) -> Operation {
        self.query = query
        if let x = query.query {
            if (x == "TEST_ERR_CASE") {
                completionHandler(nil, NSError(domain: "Test", code: 101, userInfo: nil));
                return Operation();
            }
        }
        completionHandler(result, nil)
        // This does nothing; it's just to fit the mock:
        return Operation()
    }
}
