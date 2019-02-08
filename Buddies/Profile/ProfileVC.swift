//
//  ProfileVC.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, SettingsVCDelegate {
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var settings_TopicsNotifications: Bool = true
    var settings_JoinedActivityNotifications: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2

        loadProfileData()
    }
    
    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                        storageManger: StorageManager = StorageManager.shared,
                        users: CollectionReference = Firestore.firestore().collection("users")) {
        
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
            
            self.settings_TopicsNotifications =
                data?["should_send_activity_suggestion_notification"] as? Bool ?? true
            self.settings_JoinedActivityNotifications =
                data?["should_send_joined_activity_notification"] as? Bool ?? true
        }
    }
    
    func setImage(with imageURL: URL, for uid: String){
        do {
            let imageData = try Data(contentsOf: imageURL)
            if let image = UIImage(data: imageData) {
                OperationQueue.main.addOperation {
                    self.onImageLoaded(image: image)
                }
            } else {
                print("Failed to load downloaded Topic image for \(uid)")
            }
        } catch {
            print("Could not load topic, \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SettingsVC {
            dest.init_TopicsNotifications = settings_TopicsNotifications
            dest.init_JoinedActivityNotifications = settings_JoinedActivityNotifications
            dest.delegate = self
        }
    }
    
    func setStarredTopicNotification(to value: Bool) {
        let collection = Firestore.firestore().collection("users")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        collection.document(uid).setData([
            "should_send_activity_suggestion_notification": value
        ], merge: true)
        
        self.settings_TopicsNotifications = value
    }
    
    func setJoinedActivityNotification(to value: Bool) {
        let collection = Firestore.firestore().collection("users")
        guard let uid = Auth.auth().currentUser?.uid else { return }

        collection.document(uid).setData([
            "should_send_joined_activity_notification": value
        ], merge: true)

        self.settings_JoinedActivityNotifications = value
    }
}
