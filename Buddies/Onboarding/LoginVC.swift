//
//  LoginVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var initEmailText: String?
    var initPasswordText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = initEmailText
        passwordField.text = initPasswordText
    }
    
    func showMessagePrompt(_ msg: String) {
        let alertController = UIAlertController(title: "Login Error", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUpWithEmail(_ sender: Any) {
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
        
        getAuthHandler().createUser(
            email: email,
            password: password,
            onError: showMessagePrompt,
            onSuccess: { user in BuddiesStoryboard.Main.goTo() }
        )
    }
    
    func getAuthHandler() -> AuthHandler {
        return AuthHandler(auth: Auth.auth())
    }
    
    @IBAction func signUpWithFacebook(_ sender: Any) {
        getAuthHandler().logInWithFacebook(
            ref: self,
            onError: showMessagePrompt,
            onSuccess: { user in BuddiesStoryboard.Main.goTo() }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? LoginExistingVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
    }
}
