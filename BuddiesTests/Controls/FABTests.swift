//
//  FABTests
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class FABTests: XCTestCase {
    func testFABClickShowsCreateView() {
        let expectation = self.expectation(description: "create activity presented")
        let triggerVC: MyActivitiesVC = BuddiesStoryboard.Main.viewController(withID: "my-activities")
        UIApplication.setRootView(triggerVC, animated: false)
        _ = triggerVC.view // Make sure view is loaded
        
        XCTAssert(Testing.getTopViewController() == triggerVC)
        
        let fab = triggerVC.fab!
        
        // Set up callback await
        fab._createActivityPresentedHook = {
            expectation.fulfill()
        }
        fab.button.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10)
    
        XCTAssert(Testing.getTopViewController() != triggerVC)
        XCTAssert(Testing.getTopViewController() is CreateActivityVC)
    }
}
