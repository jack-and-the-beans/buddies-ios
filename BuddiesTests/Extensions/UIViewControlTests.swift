//
//  UIViewControlTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies

class UIViewControlTests: XCTestCase {
    func testSetupHideKeyboardOnTap() {
        let myVC = UIApplication.shared.keyWindow!.rootViewController!
        
        let nRecognizersBefore = myVC.view.gestureRecognizers?.count ?? 0
        myVC.setupHideKeyboardOnTap()
        let nRecognizersAfter = myVC.view.gestureRecognizers!.count
        
        XCTAssert(nRecognizersBefore + 1 == nRecognizersAfter)
    }

}
