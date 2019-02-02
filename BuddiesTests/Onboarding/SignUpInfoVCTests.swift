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
    
    func testfinishSignUp(){
        
        
        let handler = MockAuthHandler()
        vc._authHandler = handler
        self.addTeardownBlock { self.vc._authHandler = nil }
        
        let values: [(String, String, String, Int)] = [
            ("example@example.com", "myGoodP@ssword1", "Hello1", 1),
            ("example2@example.com", "myGoodP@ssword2", "Hello2", 1),
            ("example3@example.com", "myGoodP@ssword3", "Hello3", 1),
            ("example4@example.com", "myGoodP@ssword4", "Hello4", 1),
            ("example5@example.com", "myGoodP@ssword5", "Hello5", 1),
            ("example6@example.com", "myGoodP@ssword6", "Hello6", 1),
            ("example7@example.com", "myGoodP@ssword7", "Hello7", 1),
            ]
        
        
        for (email, password, bio, nExpectedCalls) in values {
            
            //sign in to allow auth to get UI
            //prepare VC
            handler.nCallsGetUID = 0
            vc.bioText.text = bio
            vc.finishSignUp(self)
            
            //check bio with bio that should be in firebase
            if let UID = Auth.auth().currentUser?.uid
            {
                let docRef = FirestoreManager.shared.db.collection("users").document(UID)
                
                docRef.getDocument { (document, error) in
                    
                    if let document = document, document.exists {
                        let fbBio = document.get("bio") as! String
                        XCTAssert(bio == fbBio)
                    } else {
                       XCTAssert(false)
                    }
                }
                
                XCTAssert(handler.nCallsGetUID == nExpectedCalls, "Expected: \(nExpectedCalls) Actual: \(handler.nCallsCreateUser) Bio: \(bio ?? "nil")")
            }
            else{
                XCTAssert(false)
            }
            
            /*handler.signOut(onError: ProfileVC.showMessagePrompt()) {
                BuddiesStoryboard.Login.goTo()
            }*/

        }
        
    }
    
    
}
