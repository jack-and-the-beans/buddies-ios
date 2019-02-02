//
//  SignUpInfoVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class SignUpInfoVC: LoginBase {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBOutlet weak var bioText: UITextView!
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        if let UID = Auth.auth().currentUser?.uid
        {
            //set bio text
            FirestoreManager().db.collection("users").document(UID).setData([
                "bio": bioText.text!
                ], merge: true)
            BuddiesStoryboard.Main.goTo()
        }
        else
        {
           self.showMessagePrompt("Unable to authorize user.")
        }


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
