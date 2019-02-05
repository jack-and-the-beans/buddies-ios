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
            
         
            let authHandler = AuthHandler(auth: Auth.auth())
            let curUID = authHandler.getUID()!
            
            //cloud storage paths / references
            let storagePath = "/users/" + curUID + "/profilePicture.jpg"
            let storageRef = StorageManager.shared.storage.reference().child(storagePath)
            
             //upload picture to storage
            let uploadTask = storageRef.putFile(from: imgUrl, metadata: nil) { metadata, error in
         
                storageRef.downloadURL { (url, error) in
                    if let downloadURL = url{
                        self.saveProfilePicURLToFirestore(url: downloadURL.absoluteString)
                    }else{
                         print("Error updating document: \(error)")
                    }
                }
            }
          
           
            // Upload completed successfully
            uploadTask.observe(.success) { snapshot in
               
                self.pictureText.text = ""
                self.buttonPicture.tintColor = UIColor.clear
                self.buttonPicture.setImage(image, for: .normal)
                self.dismiss(animated: true, completion: nil)
            }
    
        }
        
    }
    
    @IBOutlet weak var bioText: UITextView!
    
    func fillDataModel(user: UserInfo? = Auth.auth().currentUser,
                       collection: CollectionReference = Firestore.firestore().collection("users")){
        
        if let UID = user?.uid
        {
            let favTopics: [String] = []
            let blockedUsers: [String] = []
            let blockedActivities: [String] = []
            let blockedBy: [String] = []
            let dateJoined: Date = Date(timeIntervalSince1970: TimeInterval(0))
            let loc = GeoPoint.init(latitude: 10, longitude: 10)
            let email = user?.email
            
            FirestoreManager.shared.db.collection("users").document(UID).setData([
                "favorite_topics": favTopics,
                "blocked_users": blockedUsers,
                "blocked_activities": blockedActivities,
                "blocked_by": blockedBy,
                "date_joined": dateJoined,
                "location" : loc,
                "email": email
                ], merge: true)
            
        }else{
            print("Unable to authorize user.")
        }
        
    }
    
    
    func saveProfilePicURLToFirestore(
        url: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("users")){
        
        if let UID = user?.uid
        {
            FirestoreManager.shared.db.collection("users").document(UID).setData([
                "image_url": url
                ], merge: true)
        }
        else
        {
            print("Unable to authorize user.")
        }
    }
    
    
    func saveBioToFirestore(
        bio: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("users")){
     
        if let UID = user?.uid
        {
            FirestoreManager.shared.db.collection("users").document(UID).setData([
            "bio": bio
            ], merge: true)
        }
        else
        {
            print("Unable to authorize user.")
        }
        
        
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        saveBioToFirestore(bio: bioText.text)
        fillDataModel()
        BuddiesStoryboard.Main.goTo()
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
