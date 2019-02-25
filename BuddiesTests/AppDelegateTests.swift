//
//  AppDelegateTests.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/7/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies
import Firebase
import FirebaseFirestore

class AppDelegateTests: XCTestCase {
    func testDelType() {
        XCTAssertNotNil(UIApplication.shared.delegate as? AppDelegate)
    }

    func testGetHasUserDoc_UserNil() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }

        let expectation = self.expectation(description: "User doc confirmed bad")
        
        let ref = MockCollectionReference()
        app.getHasUserDoc(callback: { result in
            if !result { expectation.fulfill() }
        }, uid: nil, dataAccess: nil, src: ref)
        
        waitForExpectations(timeout: 2)
    }
    
    func testGetHasUserDoc_NoImage() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        let expectation = self.expectation(description: "User doc confirmed bad")

        let uid = MockExistingUser().uid
        let doc = MockDocumentReference()
        let ref = MockCollectionReference()
        
        ref.documents[uid] = doc
        doc.exposedData["bio"] = "blah blah"
        
        app.getHasUserDoc(callback: { result in
            if !result { expectation.fulfill() }
        }, uid: uid, dataAccess: nil, src: ref)
        
        waitForExpectations(timeout: 2)
    }
    
    func testGetHasUserDoc_NoBio() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        let expectation = self.expectation(description: "User doc confirmed bad")
        
        let uid = MockExistingUser().uid
        let doc = MockDocumentReference()
        let ref = MockCollectionReference()
        
        ref.documents[uid] = doc
        doc.exposedData["image_url"] = "my_image_url"
        
        app.getHasUserDoc(callback: { result in
            if !result { expectation.fulfill() }
        }, uid: uid, dataAccess: nil, src: ref)
        
        waitForExpectations(timeout: 2)
    }
    
    func testGetHasUserDoc_Valid() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        let expectation = self.expectation(description: "User doc confirmed good")
        
        let uid = MockExistingUser().uid
        let doc = MockDocumentReference()
        let ref = MockCollectionReference()
        
        ref.documents[uid] = doc
        doc.exposedData["bio"] = "blah blah"
        doc.exposedData["image_url"] = "my_image_url"
        doc.exposedData["name"] = "george"
        doc.exposedData["date_joined"] = Timestamp(date: Date())
        
        app.getHasUserDoc(callback: { result in
            if result { expectation.fulfill() }
            else { print("uh whoops") }
        }, uid: uid, dataAccess: nil, src: ref)
        
        waitForExpectations(timeout: 2)
    }
    
    func testSetupApp_LoggedInWithDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupInitialView(isLoggedIn: true) {
            callback in callback(true)
        }
    }
    
    func testSetupApp_LoggedOutWithDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupInitialView(isLoggedIn: false) {
            callback in callback(true)
        }
    }
    
    func testSetupApp_LoggedInNoDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupInitialView(isLoggedIn: true) {
            callback in callback(false)
        }
    }
    
    func testSetupApp_LoggedOutNoDoc() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            XCTAssertTrue(false, "No app delegate :(")
            return
        }
        
        app.setupInitialView(isLoggedIn: false) {
            callback in callback(false)
        }
    }
}
