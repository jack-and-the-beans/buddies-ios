//
//  LoginVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: LoginBase {
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var haveAcctButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "loginBase"
        emailField.text = initEmailText
        passwordField.text = initPasswordText
    }
    
    override func getTopField() -> UIView {
        return firstNameField;
    }
    
    @IBAction func signUpWithEmail() {
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
        
        guard let name = firstNameField.text else {
            showMessagePrompt("You must enter a name")
            return
        }
        
        guard name != "" else {
            showMessagePrompt("You must enter a name")
            return
        }
        
        getAuthHandler().createUser(
            email: email,
            password: password,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { user in self.performSegue(withIdentifier: "GetSignUpInfo", sender: self)}
        )
    }
    
    @IBAction func signUpWithFacebook() {
        
        let tempAuthHandler = getAuthHandler()
        tempAuthHandler.logInWithFacebook(
            ref: self,
            onError: { msg in self.showMessagePrompt(msg) },
            onSuccess: { user in
                if(tempAuthHandler.isNewUser) {
                    if let fbFirstName = user.displayName?.split(separator: " ")[0] {
                        self.firstNameField.text = String(fbFirstName)
                    }
                    self.performSegue(withIdentifier: "GetSignUpInfo", sender: self)
                }
                else {
                    BuddiesStoryboard.Main.goTo()
                }
                
               
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginExistingVC {
            dest.initEmailText = emailField.text
            dest.initPasswordText = passwordField.text
        }
        
        if let dest = segue.destination as? SignUpInfoVC {
            dest.myFirstName = firstNameField.text
        }
    }
}
