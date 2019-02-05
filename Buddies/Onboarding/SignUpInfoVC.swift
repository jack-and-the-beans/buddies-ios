//
//  SignUpInfoVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Photos
import Firebase
import Firebase

class SignUpInfoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        buttonPicture.layer.cornerRadius = buttonPicture.frame.size.width / 2
        
    }
    
    @IBOutlet weak var pictureText: UILabel!
    @IBOutlet weak var buttonPicture: UIButton!
    
    @IBAction func changePicture(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            
            let imgName = imgUrl.lastPathComponent
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let localPath = documentDirectory?.appending(imgName)
            
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let data = image.pngData()! as NSData
            data.write(toFile: localPath!, atomically: true)
            
            

            let photoURL = URL.init(fileURLWithPath: localPath!)
            
            let authHandler = AuthHandler(auth: Auth.auth())
            let curUID = authHandler.getUID()!
            
            let storagePath = "/users/" + curUID + "/profilePicture.jpg"
            let storageRef = StorageManager.shared.storage.reference().child(storagePath)
            
            let uploadTask = storageRef.putFile(from: imgUrl, metadata: nil) { metadata, error in
         
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url{
                    
                    FirestoreManager.shared.db.collection("users").document(curUID).setData([
                        "image_url": downloadURL.absoluteString
                        ], merge: true)
                    }else{
                        
                    }
                }
            }
          
           
            
            uploadTask.observe(.success) { snapshot in
                // Upload completed successfully
                
                self.pictureText.text = ""
                self.buttonPicture.tintColor = UIColor.clear
                self.buttonPicture.setImage(image, for: .normal)
                self.dismiss(animated: true, completion: nil)
            }
    
        }
        
    }
    
    @IBOutlet weak var bioText: UITextView!
    
    func fillDataModel(UID: String){
        
        let favTopics: [String] = []
        let blockedUsers: [String] = []
        let blockedActivities: [String] = []
        let blockedBy: [String] = []
        let dateJoined = Date()
        let loc = GeoPoint.init(latitude: 10, longitude: 10)
        
        FirestoreManager.shared.db.collection("users").document(UID).setData([
            "favorite_topics": favTopics,
            "blocked_users": blockedUsers,
            "blocked_activities": blockedActivities,
            "blocked_by": blockedBy,
            "date_joined": dateJoined,
            "location" : loc
            ], merge: true)
        BuddiesStoryboard.Main.goTo()
        
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        let authHandler = AuthHandler(auth: Auth.auth())
        
        if let UID = authHandler.getUID()
        {
            
        
            if let bio = bioText.text{
                //set bio text
                FirestoreManager.shared.db.collection("users").document(UID).setData([
                    "bio": bio,
                    "uid": UID,
                    "email": authHandler.getEmail()!
                    ], merge: true)
                
                fillDataModel(UID: UID)
                BuddiesStoryboard.Main.goTo()
            }
            else
            {
                bioText.text = "About you..."
            }
            
        }
        else
        {
           print("Unable to authorize user.")
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
