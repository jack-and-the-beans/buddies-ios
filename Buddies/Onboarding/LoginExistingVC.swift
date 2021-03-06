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
        self.view.accessibilityIdentifier = "loginExistingVC"
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
            onSuccess: { _ in /* Navigation to main page is
                                 handled by AppDelegate */ }
        )
    }
    
    @IBAction func facebookLogin() {
        getAuthHandler().logInWithFacebook(
            ref: self,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { _ in /* Navigation to main page is
                                 handled by AppDelegate */ }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
    }
}
