//
//  LoginExistingVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class LoginExistingVC: LoginBase {
    @IBOutlet weak var emailField: UnderlinedTextbox!
    @IBOutlet weak var passwordField: UnderlinedTextbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = initEmailText
        passwordField.text = initPasswordText
    }
    
    override func getTopField() -> UIView {
        return emailField;
    }
    
    @IBAction func logIn() {
        guard let password = passwordField.text else {
            showMessagePrompt("You must enter a password")
            return
        }
        
        guard password != "" else {
            showMessagePrompt("You must enter a password")
            return
        }
        
        guard let email = emailField.text else {
            showMessagePrompt("You must enter an email")
            return
        }
        
        guard email != "" else {
            showMessagePrompt("You must enter an email")
            return
        }
        
        getAuthHandler().logIn(
            email: email,
            password: password,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { user in self.handleOnLogIn(user: user) }
        )
    }
    
    func handleOnLogIn(user: User) {
        let me = Firestore.firestore().collection("users").document(user.uid)
        
        me.getDocument { (snap, err) in
            guard
                let snap = snap
                , snap.exists
                , let data = snap.data()
                , let _ = data["image_url"]
                , let _ = data["bio"] else {
                    UIApplication.setRootView(
                        BuddiesStoryboard.Login.viewController(withID: "SignUpInfo")
                    )
                    return
            }
            
            // Show home page
            BuddiesStoryboard.Main.goTo()
        }
    }
    
    @IBAction func facebookLogin() {
        getAuthHandler().logInWithFacebook(
            ref: self,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { user in self.handleOnLogIn(user: user) }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
    }
}
