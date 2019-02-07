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
            onSuccess: { user in self.handleOnLogIn(uid: user.uid) }
        )
    }
    
    func handleOnLogIn(uid: String,
                       app: AppDelegate? = UIApplication.shared.delegate as? AppDelegate,
                       users: CollectionReference = Firestore.firestore().collection("users")) {
        guard let app = app else {
            print("no app given :(")
            return
        }
        
        app.tryLoadMainPage { callback in app.getHasUserDoc(callback: callback) }
    }
    
    @IBAction func facebookLogin() {
        getAuthHandler().logInWithFacebook(
            ref: self,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { user in self.handleOnLogIn(uid: user.uid) }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
    }
}
