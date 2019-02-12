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
    private let notifications: NotificationService!
    
    var isNewUser = false

    init(auth: Auth!) {
        self.auth = auth
        self.notifications = NotificationService()
    }
    
    func isLoggedIn() -> Bool {
        return auth.currentUser != nil
    }
    

    
    func saveFacebookAccessTokenToFirestore(
        facebookAccessToken: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("users")){
        
        if let UID = user?.uid
        {
            collection.document(UID).setData([
                "facebook_access_token": facebookAccessToken
                ], merge: true)
        }
        else
        {
            print("Unable to authorize user.")
        }
        
        
    }
    
    
    func logInWithFacebook(ref: UIViewController, onError: @escaping (String) -> Void, onSuccess: @escaping (Firebase.User) -> Void) {
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
                        
                        self.isNewUser = (result?.additionalUserInfo?.isNewUser)!
                        
                        self.notifications.registerForNotifications()
                        
                        //save facebook access token for auth later on
                        self.saveFacebookAccessTokenToFirestore(facebookAccessToken:(FBSDKAccessToken.current()?.tokenString)!)
                        
                        onSuccess(result!.user)
                    }
                }
            }
        })
    }
    
    func createUser(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (Firebase.User) -> Void) {
        
        auth.createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                onError(error.localizedDescription)
            }
            else if let result = result {
                // TODO: Push to firestore first
                self.notifications.registerForNotifications()
                onSuccess(result.user)
            }
        }
    }
    
    
    
    func logIn(email: String, password: String, onError: @escaping (String) -> Void, onSuccess: @escaping (Firebase.User) -> Void) {
        
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                onError(error.localizedDescription)
            }
            else if let result = result {
                // TODO: Push to firestore first
                self.notifications.registerForNotifications()
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
