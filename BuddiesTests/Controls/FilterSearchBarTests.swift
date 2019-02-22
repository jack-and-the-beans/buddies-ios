//
//  FilterSearchBarTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/22/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import UIKit
@testable import Buddies

class TestFilterSearchBarDelegate : FilterSearchBarDelegate {
    var onDisplay: (()->Void)?
    
    func endEditing() { /*Do nothing*/ }
    func display(activities: [ActivityId]) { onDisplay?() }
    func getTopics() -> [String] { return [ "j0FFY5VI4Ti6SZ5jUsDJ" ] }
}

class FilterSearchBarTests: XCTestCase {

    var parent: UIView!
    var bar: FilterSearchBar!
    var deli: TestFilterSearchBarDelegate!
    
    override func setUp() {
        let client = TestClient(appID: "foo", apiKey: "bar")
        let search = AlgoliaSearch(algoliaClient: client)
        
        parent = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        
        bar = FilterSearchBar(frame: parent.frame)
        bar.api = search
        
        deli = TestFilterSearchBarDelegate()
        bar.displayDelegate = deli
        
        parent.addSubview(bar)
    }

    func testExample() {
        XCTAssert(parent.subviews.count == 1)
        
        // Toggle the menu ON
        bar.onFilterTapped()
        
        XCTAssert(parent.subviews.count == 2)
        
        // Toggle the menu OFF
        bar.onFilterTapped()
        
        XCTAssert(parent.subviews.count == 1)
    }
    
    func testSearchBarSearchButtonClicked() {
        let exp = self.expectation(description: "search triggered")
        
        deli.onDisplay = { exp.fulfill() }
        
        bar.searchBarSearchButtonClicked(bar)
        
        self.waitForExpectations(timeout: 1)
    }
    
    func testSearchBarCancelButtonClicked() {
        let exp = self.expectation(description: "search triggered")
        
        deli.onDisplay = { exp.fulfill() }
        
        bar.searchBarCancelButtonClicked(bar)
        
        self.waitForExpectations(timeout: 1)
    }
    
    func testTextDidChange() {
        let exp = self.expectation(description: "search triggered")
        
        deli.onDisplay = { exp.fulfill() }
        
        XCTAssertNil(bar.searchTimer)
        
        bar.searchBar(bar, textDidChange: "new text")
        
        XCTAssertNotNil(bar.searchTimer)
        
        self.waitForExpectations(timeout: 2)
    }
    
    func testIgnoredIfNoChange() {
        let exp = self.expectation(description: "search triggered")

        deli.onDisplay = { exp.fulfill() }
        bar.searchBar(bar, textDidChange: "new text")
        
        self.waitForExpectations(timeout: 1)

        deli.onDisplay = { XCTAssertTrue(false) } // Fail if data is reloaded!
        bar.searchBar(bar, textDidChange: "new text")
    }
}
