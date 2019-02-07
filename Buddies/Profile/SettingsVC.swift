//
//  SettingsVC.swift
//  Buddies
//
//  Created by Jake Thurman on 2/6/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UITableViewController {
    @IBOutlet weak var joinnedActivityNotificationToggle: UISwitch!
    @IBOutlet weak var starredTopicNotificationToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onStarredTopicNotificationChange() {
    }
    
    @IBAction func onJoinedActivityNotificationChange() {
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        if usedFacebook() {
            let alert = UIAlertController(title: "Delete your account?", message: "Please confirm if you'd like to delete your account.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.deleteAccountFacebook()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "confirmDeleteAccountEmail", sender: self)
        }
    }
    
    func usedFacebook(
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("users")) -> Bool{
        
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case "facebook.com":
                    return true
                default:
                    continue
                }
            }
        }
        
        return false
    }
    
    func showMessagePrompt(_ msg: String) {
        let alertController = UIAlertController(title: "Login Error", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        let auth = AuthHandler(auth: Auth.auth())
        auth.signOut(onError: showMessagePrompt) {
            BuddiesStoryboard.Login.goTo()
        }
    }
    
    
    func deleteAccountFacebook() {
        
        guard let user = Auth.auth().currentUser else {return}
        let docRef = FirestoreManager.shared.db.collection("users").document(user.uid)
        
        docRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                //get token from firestore
                let token = document.get("facebook_access_token") as! String
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                
                user.reauthenticateAndRetrieveData(with: credential, completion: {(result, error) in
                    if error != nil {
                        self.showMessagePrompt("Could not authenticate user.")
                    } else {
                        user.delete { error in
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
                })
            } else {
                print("Document does not exist")
            }
        }
    }
}
