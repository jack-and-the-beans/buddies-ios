//
//  DeleteAccountVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/5/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import FirebaseAuth

class DeleteAccountVC: LoginBase {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func confirmDeleteAccount(_ sender: Any) {
        
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
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        //reauth user
        user?.reauthenticate(with: credential) { error in
            if error != nil {
                self.showMessagePrompt("Your email or password is incorrect.")
            } else {
                
                //delete user
                user?.delete { error in
                    
                    if error != nil {
                        self.showMessagePrompt("Could not delete user.")
                    } else {
                        
                        //sign out user after deleting their account
                        let auth = AuthHandler(auth: Auth.auth())
                        auth.signOut(onError: self.showMessagePrompt) {
                            BuddiesStoryboard.Login.goTo()
                        }
                    }
                }
            }
        }
        
    }
    
}
