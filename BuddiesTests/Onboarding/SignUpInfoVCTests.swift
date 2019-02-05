//
//  SignUpInfoVCTests.swift
//  BuddiesTests
//
//  Created by Grant Yurisic on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
import Firebase
@testable import Buddies

//temp
class ExistingUser : NSObject, UserInfo {
    var providerID: String = "test"
    
    var displayName: String? = "test"
    
    var photoURL: URL? = nil
    
    var email: String? = "test"
    
    var phoneNumber: String? = "test"
    
    var uid: String = "test_uid"
}

//temp
class TestCollection : CollectionReference {
    
    var test_bio: String? = nil
    var test_fav_topics: [String]? = []
    var test_blocked_users: [String]? = []
    var test_blocked_activities: [String]? = []
    var test_blocked_by: [String]? = []
    var test_date_joined: Date? = nil
    var test_loc: GeoPoint? = nil
    var test_email : String? = nil
    
    var doc = TestDoc()
    
    override func document(_ documentPath: String) -> DocumentReference {
        return doc
    }
    
    class TestDoc : DocumentReference {
        
        var test_bio: String? = nil
        var test_fav_topics: [String]? = []
        var test_blocked_users: [String]? = []
        var test_blocked_activities: [String]? = []
        var test_blocked_by: [String]? = []
        var test_date_joined: Date? = nil
        var test_loc: GeoPoint? = nil
        var test_email : String? = nil
        
        override func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)? = nil) {
            
            test_bio = fields[AnyHashable("bio")] as? String
            test_fav_topics = fields[AnyHashable("fav_topics")] as? [String]
            test_blocked_users = fields[AnyHashable("blocked_users")] as? [String]
            test_blocked_activities = fields[AnyHashable("blocked_activities")] as? [String]
            test_blocked_by = fields[AnyHashable("blocked_by")] as? [String]
            test_date_joined = fields[AnyHashable("test_fav_topics")] as? Date
            test_loc  = fields[AnyHashable("test_fav_topics")] as? GeoPoint
            test_email = fields[AnyHashable("test_email")] as? String
            
        }
        
        override func setData(_ documentData: [String : Any], merge: Bool, completion: ((Error?) -> Void)? = nil) {
            test_bio = documentData["bio"] as? String
            if (test_bio?.count == 0) {
                let err = NSError(domain: "None", code: -1, userInfo: ["name": "none"])
                guard let onErr = completion else { return }
                
                onErr(err)
            }
        }
        
        // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
        init(workaround _: Void = ()) {}
    }
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {}
}


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
    
    func testSaveProfilePicURLToFirestore()
    {
        
    }
    
    func testSaveBioToFirestore()
    {
        
    }
    
    func testFillDataModel()
    {
        
    }
    
    
}
