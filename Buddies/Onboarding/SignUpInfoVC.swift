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
    
    var canceler: Canceler?
    var user: LoggedInUser?
    @IBOutlet weak var finishButton: BuddyButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func getTopField() -> UIView {
        return firstName
    }
    
    deinit {
        canceler?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        
        // Do any additional setup after loading the view.
        bioText.delegate = self
        bioText.textColor = UIColor.lightGray
        bioText.layer.cornerRadius = Theme.cornerRadius
        bioText.textContainerInset = UIEdgeInsets(top: 12 ,left: 7, bottom: 12, right: 7)
        bioText.layer.borderColor = Theme.fieldBorder.cgColor
        bioText.layer.borderWidth = 2
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        buttonPicture.layer.cornerRadius = buttonPicture.frame.size.width / 2
        
        LocationPersistence.instance.makeSureWeHaveLocationAccess(from: self)
        cancelButton.isEnabled = false
        cancelButton.setTitleColor(UIColor.clear, for: .normal)
        
        firstName.text = myFirstName ?? stringUntil(Auth.auth().currentUser?.displayName, " ")
        
        // -- Handle edit mode --
        canceler = DataAccessor.instance.useLoggedInUser { user in
            // On first load
            if let user = user, self.user == nil {
                self.finishButton.setTitle("Save", for: .normal)
                self.cancelButton.isEnabled = true
                self.cancelButton.setTitleColor(Theme.themeAlt, for: .normal)
                
                self.buttonPicture.setImage(user.image, for: .normal)
                self.firstName.text = user.name
                self.bioText.text = user.bio
                self.bioText.textColor = UIColor.black
            }
            
            self.user = user
        }
        
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
        textView.layer.borderColor = Theme.fieldBorderFocused.cgColor
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderColor = Theme.fieldBorder.cgColor
        
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
    
    func getNextImageVersion() -> Int {
        return (self.user?.imageVersion ?? -1) + 1
    }
    
    func uploadProfilePicToCloudStorage(imgUrl: URL, user: UserInfo? = Auth.auth().currentUser){
        
        if let curUID = user?.uid {
            //cloud storage paths / references
            let storagePath = "/users/" + curUID + "/\(getNextImageVersion()).jpg"
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
            
            // Pretend we have the image now
            self.user?.image = image
            
            cacheImage(imgUrl: imgUrl)
         
            uploadProfilePicToCloudStorage(imgUrl: imgUrl)
            
            self.dismiss(animated: true, completion: nil)
          
        }
        
    }
    
    func cacheImage(imgUrl: URL,
                    user: UserInfo? = Auth.auth().currentUser,
                    manager: StorageManager = StorageManager.shared) {
        if let uid = user?.uid,
           let localUrl = manager.localURL(for: "\(uid)_\(getNextImageVersion())") {
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
            
            collection.document(UID).setData([
                "favorite_topics": favTopics,
                "blocked_users": blockedUsers,
                "blocked_activities": blockedActivities,
                "blocked_by": blockedBy,
                "date_joined": dateJoined,
                "location" : loc,
                "email": email ?? "",
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
                "image_url": url,
                "image_version": getNextImageVersion(),
            ], merge: true)
        }
        else {
            print("Unable to authorize user.")
        }
    }
    
    
    func saveFieldsToFirestore(
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("accounts")){
     
        if let UID = user?.uid
        {
            collection.document(UID).setData([
                "bio": bioText.text,
                "name": firstName.text ?? ""
            ], merge: true)
        }
        else
        {
            print("Unable to authorize user.")
        }
        
        
    }
    @IBAction func cancelEdit(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func finishSignUp(_ sender: Any) {
        
        if bioText.textColor! == UIColor.lightGray || buttonPicture.imageView?.image == nil || (firstName.text ?? "").isEmpty {
            let alert = UIAlertController(title: "Missing Information", message: "Make sure you've filled everything in.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        else {
            saveFieldsToFirestore()
            
            // For edit mode, dismiss the view.
            if let _ = user {
                self.dismiss(animated: true)
            }
            else {
                fillDataModel()
            }
            
            /* navigation to main storyboard
               is handled by AppDelegate */
        }
    }
}
