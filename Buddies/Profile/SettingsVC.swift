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
    @IBOutlet weak var joinedActivityNotificationToggle: UISwitch!
    @IBOutlet weak var topicNotificationToggle: UISwitch!

    var stopListeningToUser: Canceler?
    var userRef: LoggedInUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopListeningToUser?()
    }
    
    func renderView(uid: String = Auth.auth().currentUser!.uid,
                    dataAccess: DataAccessor = DataAccessor.instance) {
        var isFirstRender = true
        
        self.stopListeningToUser = dataAccess.useLoggedInUser { user in
            guard let user = user else { return }
            self.joinedActivityNotificationToggle.setOn(
                user.shouldSendJoinedActivityNotification,
                animated: !isFirstRender)
            
            self.topicNotificationToggle.setOn(
                user.shouldSendActivitySuggestionNotification,
                animated: !isFirstRender)
            
            isFirstRender = false
            
            self.userRef = user
        }
    }
    
    
    @IBAction func onStarredTopicNotificationChange() {
        self.userRef?.shouldSendActivitySuggestionNotification = topicNotificationToggle.isOn
    }
    
    @IBAction func onJoinedActivityNotificationChange() {
        self.userRef?.shouldSendJoinedActivityNotification = joinedActivityNotificationToggle.isOn
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
    
    func usedFacebook(user: UserInfo? = Auth.auth().currentUser) -> Bool{
        
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
        let alertController = UIAlertController(title: "Account Error", message: msg, preferredStyle: .alert)
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
        guard let user = Auth.auth().currentUser else { return }
        guard let token = userRef?.facebookId else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        
        user.reauthenticateAndRetrieveData(with: credential, completion: {(result, error) in
            if let error = error {
                self.showMessagePrompt("Reauthentication with facebook failed.\n\n\(error.localizedDescription)")
                return
            }
            
            user.delete { error in
                if let error = error {
                    self.showMessagePrompt("Delete account failed.\n\n\(error.localizedDescription)")
                    return
                }
                
                //sign out user after deleting their account
                let auth = AuthHandler(auth: Auth.auth())
                auth.signOut(onError: self.showMessagePrompt) {
                    BuddiesStoryboard.Login.goTo()
                }
            }
        })
    }
}
