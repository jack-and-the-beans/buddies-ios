//
//  SignUpInfoVCTests.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/5/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
import FirebaseFirestore

@testable import Buddies
class SignUpInfoVCTests: XCTestCase {
    
    var vc: SignUpInfoVC!
    
    override func setUp() {
        vc = BuddiesStoryboard.Login.viewController(withID: "SignUpInfo")
        UIApplication.setRootView(vc, animated: false)
        _ = vc.view // Make sure view is loaded
    }
    
    override func tearDown() {
        UIApplication.shared.keyWindow?.rootViewController = nil
        vc = nil
    }
    
    
    
    func testInitLifecycle() {
        XCTAssertNotNil(vc.view, "View should be loaded")
    }
    
    
    func testFillDataModel()
    {
        let vc = SignUpInfoVC()
        let collection = MockCollectionReference()
        let user = MockExistingUser()
        
        vc.fillDataModel( user: user, collection: collection)
        
        let doc = collection.document("test_uid") as! MockDocumentReference
        
        XCTAssert(doc.exposedData["favorite_topics"] as? [String] != nil, "Saves empty array for favorite_topics if user is authenticated.")
        XCTAssert(doc.exposedData["blocked_users"] as? [String] != nil, "Saves empty array for blocked_users if user is authenticated.")
        XCTAssert(doc.exposedData["blocked_activities"] as? [String] != nil, "Saves empty array for blocked_activities if user is authenticated.")
        XCTAssert(doc.exposedData["blocked_by"] as? [String] != nil, "Saves empty array for blocked_by if user is authenticated.")
        XCTAssert(doc.exposedData["date_joined"] as? Timestamp != nil, "Saves dummy date for date_joined if user is authenticated.")
        XCTAssert(doc.exposedData["location"] as? GeoPoint != nil, "Saves dummy location for location if user is authenticated.")
        XCTAssert(doc.exposedData["email"] as? String == "test", "Saves dummy email if user is authenticated.")
    }
    
    
    func testTextViewDidBeginEditing()
    {
        let vc = SignUpInfoVC()
        let tempTextView = UITextView()
        vc.bioText = tempTextView
        vc.bioText.textColor = UIColor.lightGray
        vc.bioText.text = "About you..."
        vc.textViewDidBeginEditing(vc.bioText)
        
        XCTAssert(vc.bioText.text.isEmpty, "Bio text view is empty.")
        XCTAssert(vc.bioText.textColor == UIColor.black, "Bio text is black.")
    }
    
    func testTextViewDidEndEditing(){
        
        let vc = SignUpInfoVC()
        let tempTextView = UITextView()
        vc.bioText = tempTextView
        vc.bioText.text = nil
        vc.textViewDidEndEditing(vc.bioText)
        
        XCTAssert(vc.bioText.text == "About you...", "Bio text is 'About you...'")
        XCTAssert(vc.bioText.textColor == UIColor.lightGray, "Bio text is light gray.")
    }
    
    
    func testSaveProfilePicURLToFirestore()
    {
        let vc = SignUpInfoVC()
        let collection = MockCollectionReference()
        let user = MockExistingUser()
        
        vc.saveProfilePicURLToFirestore(
            url: "url/for/image",
            user: user,
            collection: collection
        )
        
        let doc = collection.document("test_uid") as! MockDocumentReference
        
        XCTAssert(doc.exposedData["image_url"] as! String == "url/for/image", "Saves download url for profile picture if user is authenticated.")
    }
    
    func testSaveBioToFirestore(){
        let vc = SignUpInfoVC()
        let collection = MockCollectionReference()
        let user = MockExistingUser()
        
        vc.saveBioToFirestore(
            bio: "biography",
            user: user,
            collection: collection
        )
        
        let doc = collection.document("test_uid") as! MockDocumentReference
        
        XCTAssert(doc.exposedData["bio"] as! String == "biography", "Saves bio if user is authenticated.")
    }
}
