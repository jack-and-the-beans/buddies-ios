//
//  LoginExistingVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class LoginExistingVC: UIViewController {
    
    @IBOutlet weak var emailField: UnderlinedTextbox!
    
    @IBOutlet weak var passwordField: UnderlinedTextbox!
    
    var initEmailText: String?
    var initPasswordText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = initEmailText
        passwordField.text = initPasswordText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
    }
    
    func showMessagePrompt(_ msg: String) {
        let alertController = UIAlertController(title: "Login Error", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getAuthHandler() -> AuthHandler {
        return AuthHandler(auth: Auth.auth())
    }
    
    @IBAction func logIn(_ sender: Any) {
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
            onError: showMessagePrompt,
            onSuccess: { user in BuddiesStoryboard.Main.goTo() }
        )
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        getAuthHandler().logInWithFacebook(
            ref: self,
            onError: showMessagePrompt,
            onSuccess: { user in BuddiesStoryboard.Main.goTo() }
        )
    }
    
}
