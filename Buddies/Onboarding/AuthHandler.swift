//
//  AuthHandler.swift
//  Buddies
//
//  Created by Jake Thurman on 1/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

class AuthHandler {
    private let auth: Auth!
    
    init(auth: Auth!) {
        self.auth = auth
    }
    
    func isLoggedIn() -> Bool {
        return auth.currentUser != nil
    }
    
    func logInWithFacebook(ref: UIViewController, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: ["email"], from: ref, handler: { (result, error) in
            if let error = error {
                onError(error.localizedDescription)
            } else if !result!.isCancelled {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.auth.signInAndRetrieveData(with: credential) { (result, error) in
                    if let error = error {
                        onError(error.localizedDescription)
                    }
                    else {
                        onSuccess(result!.user)
                    }
                }
            }
        })
    }
    
    func createUser(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                onError(error.localizedDescription)
            }
            else if let result = result {
                // TODO: Push to firestore first
                
                onSuccess(result.user)
            }
        }
    }
    
    
    
    func logIn(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (User) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                onError(error.localizedDescription)
            }
            else if let result = result {
                // TODO: Push to firestore first
                
                onSuccess(result.user)
            }
        }
    }
    
    func signOut(onError: (String) -> Void, onSuccess: () -> Void) {
        do {
            try auth.signOut()
            onSuccess()
        }
        catch let error {
            onError(error.localizedDescription)
        }
    }
}
