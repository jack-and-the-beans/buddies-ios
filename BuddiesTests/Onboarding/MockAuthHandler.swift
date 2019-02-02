//
//  MockAuth.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Firebase
@testable import Buddies

class MockAuthHandler : AuthHandler {
    var nCallsCreateUser = 0
    var nCallsLogInWithFacebook = 0
    var nCallsLogIn = 0
    var nCallsGetUID = 0
    
    init() {
        super.init(auth: nil)
    }
    
    override func createUser(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        nCallsCreateUser += 1
    }
    
    override func logInWithFacebook(ref: UIViewController, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        nCallsLogInWithFacebook += 1
    }
    
    override func logIn(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        nCallsLogIn += 1
    }
    
    override func getUID() -> String? {
        
        nCallsGetUID = nCallsGetUID + 1
        
        return super.getUID()
        
    }
    
    
}
