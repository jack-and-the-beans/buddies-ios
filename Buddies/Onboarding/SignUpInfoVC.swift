//
//  SignUpInfoVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

//https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/

import UIKit
import Photos
import Firebase

class ProfilePicOp: Operation {
    
    let imgURL : URL
    let storageRef : StorageReference
    let vc : SignUpInfoVC
    
    init(_ imgURL: URL, storageRef: StorageReference, vc: SignUpInfoVC) {
        self.imgURL = imgURL
        self.storageRef = storageRef
        self.vc = vc
    }
    
    override func main() {
        
        if isCancelled {
            return
        }
        
        let uploadTask = storageRef.putFile(from: self.imgURL, metadata: nil) { metadata, error in
            self.storageRef.downloadURL { (url, error) in
                if let downloadURL = url{
                    self.vc.saveProfilePicURLToFirestore(url: downloadURL.absoluteString)
                } else {
                    print("Error updating document: \(error!)")
                }
            }
        }
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            return
        }
    
    }
}


class SignUpInfoVC: LoginBase, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    var imagePicker = UIImagePickerController()
    var myFirstName: String?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    override func getTopField() -> UIView {
        return buttonPicture
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        // Do any additional setup after loading the view.
        bioText.delegate = self
        bioText.textColor = UIColor.lightGray
        bioText.layer.cornerRadius = Theme.cornerRadius
        bioText.textContainerInset = Theme.textAreaInset
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        bioText.layer.borderColor = Theme.fieldBorderFocused.cgColor
        bioText.layer.borderWidth = Theme.textAreaBorderWidth
        buttonPicture.layer.cornerRadius = buttonPicture.frame.size.width / 2
        
        LocationPersistence.instance.makeSureWeHaveLocationAccess(from: self)
      
         // If the user authenticated with Facebook, set
        // their profile picture to be from facebook.
        guard let user = Auth.auth().currentUser else { return }
        for userInfo in user.providerData {
            if (userInfo.providerID == "facebook.com") {
                let facebookId = userInfo.uid
                let facebookPicUrl = "https://graph.facebook.com/\(facebookId)/picture?type=large"
                
                saveProfilePicURLToFirestore(url: facebookPicUrl)
                
                _ = StorageManager.shared.downloadFile(for: facebookPicUrl, to: userInfo.uid, session: nil) { localURL in
                    do {
                        let imageData = try Data(contentsOf: localURL)
                        if let image = UIImage(data: imageData) {
                            OperationQueue.main.addOperation {
                                self.buttonPicture.setImage(image, for: .normal)
                            }
                        } else {
                            print("Failed to load downloaded User profile pic image from facebook")
                        }
                    } catch {
                        
                        print("Could not load topic, \(error)")
                    }
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "About you..."
            textView.textColor = UIColor.lightGray
        }
    }

    @IBOutlet weak var pictureButtonText: UIButton!
    @IBOutlet weak var buttonPicture: UIButton!
    
    @IBAction func changePicture(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    func uploadProfilePicToCloudStorage(imgUrl: URL, user: UserInfo? = Auth.auth().currentUser){
        
        if let curUID = user?.uid {
            //cloud storage paths / references
            let storagePath = "/users/" + curUID + "/profilePicture.jpg"
            let storageRef = StorageManager.shared.storage.reference().child(storagePath)
            
            //upload picture to storage async
            let profPicOp = ProfilePicOp(imgUrl, storageRef: storageRef, vc: self)
            let profPicOpQueue = OperationQueue()
            profPicOpQueue.name = "Profile Pic Operation Queue"
            profPicOpQueue.maxConcurrentOperationCount = 1
            profPicOpQueue.addOperation(profPicOp)
        }
        else{
            print("Unable to authenticate user.")
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

            self.pictureButtonText.isEnabled = false
            self.pictureButtonText.setTitle("", for: UIControl.State.disabled)
            self.buttonPicture.tintColor = UIColor.clear
            self.buttonPicture.setImage(image, for: .normal)
            
            cacheImage(imgUrl: imgUrl)
         
            uploadProfilePicToCloudStorage(imgUrl: imgUrl)
            
            self.dismiss(animated: true, completion: nil)
          
        }
        
    }
    
    func cacheImage(imgUrl: URL,
                    user: UserInfo? = Auth.auth().currentUser,
                    manager: StorageManager = StorageManager.shared) {
        if let uid = user?.uid,
           let localUrl = manager.localURL(for: uid) {
            manager.persistDownload(temp: imgUrl, dest: localUrl)
        }
    }
    
    @IBOutlet weak var bioText: UITextView!
    
    // returns the first part of the string `s`, up until the first occurence of the character `c`
    func stringUntil(_ s: String?, _ c: Character) -> String? {
        if let ss = s?.split(separator: c)[0] {
            return String(ss)
        }
        return nil
    }
    
    func fillDataModel(user: UserInfo? = Auth.auth().currentUser,
                       collection: CollectionReference = DataAccessor.instance.accountCollection){
        
        if let UID = user?.uid {
            let favTopics: [String] = []
            let blockedUsers: [String] = []
            let blockedActivities: [String] = []
            let blockedBy: [String] = []
            let dateJoined = Timestamp(date: Date())
            let loc = GeoPoint(latitude: 0, longitude: 0)//this should get replaced momentarily
            let email = user?.email
            let name = myFirstName
                ?? stringUntil(user?.displayName, " ")
                ?? stringUntil(email, "@")
                ?? "Nameless"
            
            collection.document(UID).setData([
                "favorite_topics": favTopics,
                "blocked_users": blockedUsers,
                "blocked_activities": blockedActivities,
                "blocked_by": blockedBy,
                "date_joined": dateJoined,
                "location" : loc,
                "email": email ?? "",
                // Handle error cases with the name safely
                "name": name
            ], merge: true)
            
        }
        else{
            print("Unable to authorize user.")
        }
        
    }
    
    
    func saveProfilePicURLToFirestore(
        url: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("accounts")){
        
        if let UID = user?.uid {
            collection.document(UID).setData([
                "image_url": url
            ], merge: true)
        }
        else {
            print("Unable to authorize user.")
        }
    }
    
    
    func saveBioToFirestore(
        bio: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("accounts")){
     
        if let UID = user?.uid
        {
            collection.document(UID).setData([
                "bio": bio
            ], merge: true)
        }
        else
        {
            print("Unable to authorize user.")
        }
        
        
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        if bioText.textColor! == UIColor.lightGray || buttonPicture.imageView?.image == nil {
            let alert = UIAlertController(title: "Finish Sign Up", message: "Please enter a bio and choose a profile picture.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        else {
            saveBioToFirestore(bio: bioText.text)
            fillDataModel()
            
            /* navigation to main storyboard
               is handled by AppDelegate */
        }
    }
}
