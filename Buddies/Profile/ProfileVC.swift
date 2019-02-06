//
//  ProfileVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2

        loadProfileData()
    }
    
    
    func loadProfileData(auth: Auth = Auth.auth(),
                        storageManger: StorageManager = StorageManager.shared,
                        users: CollectionReference = Firestore.firestore().collection("users")) {
        
        let uid = auth.currentUser!.uid
        
        if let image = storageManger.getSavedImage(filename: uid) {
            onImageLoaded(image: image)
            
            loadFromFile(uid: uid, needsImage: false, storageManger: storageManger, doc: users.document(uid))
        } else {
            loadFromFile(uid: uid, needsImage: true, storageManger: storageManger, doc: users.document(uid))
        }
    }
    
    func onImageLoaded(image: UIImage) {
        profilePic.tintColor = UIColor.clear
        profilePic.setImage(image, for: .normal)
    }
    
    func loadFromFile(uid: String,
                      needsImage: Bool,
                      storageManger: StorageManager,
                      doc: DocumentReference) {
        
        doc.getDocument { (snapshot, err) in
            guard let snapshot = snapshot else {
                print("Error loading profile document \(err!.localizedDescription)")
                return
            }
            
            let data = snapshot.data()
            
            if (needsImage) {
                guard let firebaseImageURL = data?["image_url"] as? String else {
                    print("Cannot get Image URL for \(snapshot.documentID)")
                    return
                }
                
                let _ = storageManger.downloadFile(
                    for: firebaseImageURL,
                    to: snapshot.documentID,
                    session: nil
                ) { destURL in self.setImage(with: destURL, for: snapshot.documentID) }
            }
            
            guard let bio = data?["bio"] as? String else {
                print("Cannot get bio for \(snapshot.documentID)")
                return
            }
            
            guard let name = data?["name"] as? String else {
                print("Cannot get name for \(snapshot.documentID)")
                return
            }
            
            self.bioLabel.text = bio
            self.nameLabel.text = name
        }
    }
    
    func setImage(with imageURL: URL, for uid: String){
        do {
            let imageData = try Data(contentsOf: imageURL)
            if let image = UIImage(data: imageData) {
                onImageLoaded(image: image)
            } else {
                print("Failed to load downloaded Topic image for \(uid)")
            }
        } catch {
            print("Could not load topic, \(error)")
        }
    }
}
