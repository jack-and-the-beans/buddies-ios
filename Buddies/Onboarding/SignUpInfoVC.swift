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
                }else{
                    print("Error updating document: \(error)")
                }
            }
        }
        
        // Upload completed successfully
        uploadTask.observe(.success) { snapshot in
            return
            
        }
        
        
        
    }
}


class SignUpInfoVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        bioText.layer.borderColor = ControlColors.fieldBorderFocused.cgColor
        bioText.layer.borderWidth = 2
        buttonPicture.layer.cornerRadius = buttonPicture.frame.size.width / 2
        
        // If the user authenticated with Facebook, set
        // their profile picture to be from facebook.
        guard let user = Auth.auth().currentUser else { return }
        for userInfo in user.providerData {
            if (userInfo.providerID == "facebook.com") {
                let facebookId = userInfo.uid
                let facebookPicUrl = "https://graph.facebook.com/\(facebookId)/picture?type=large"
                saveProfilePicURLToFirestore(url: facebookPicUrl)
                guard let picUrl = URL(string: facebookPicUrl) else { return }
                downloadImage(from: picUrl)
            }
        }
    }
    
    // https://stackoverflow.com/a/27712427
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let img = UIImage(data: data)
                self.buttonPicture.setImage(img, for: .normal)
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    @IBOutlet weak var pictureButtonText: UIButton!
    @IBOutlet weak var buttonPicture: UIButton!
    
    @IBAction func changePicture(_ sender: Any) {
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
            
            
            self.pictureButtonText.isEnabled = false
            self.buttonPicture.tintColor = UIColor.clear
            self.buttonPicture.setImage(image, for: .normal)
         
            let authHandler = AuthHandler(auth: Auth.auth())
            let curUID = authHandler.getUID()!
            
            //cloud storage paths / references
            let storagePath = "/users/" + curUID + "/profilePicture.jpg"
            let storageRef = StorageManager.shared.storage.reference().child(storagePath)
            
            //upload picture to storage async
            let profPicOp = ProfilePicOp(imgUrl, storageRef: storageRef, vc: self)
            let profPicOpQueue = OperationQueue()
            profPicOpQueue.name = "Profile Pic Operation Queue"
            profPicOpQueue.maxConcurrentOperationCount = 1
            profPicOpQueue.addOperation(profPicOp)
           
            self.dismiss(animated: true, completion: nil)
          
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
            
            
            collection.document(UID).setData([
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
            collection.document(UID).setData([
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
