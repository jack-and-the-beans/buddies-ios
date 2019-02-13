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
    
    var stopListeningToUser: Canceler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePic?.imageView?.layer.cornerRadius = profilePic.bounds.size.width / 2
        profilePic?.imageView?.clipsToBounds = true

        loadProfileData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopListeningToUser?()
    }
    
    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                        storageManger: StorageManager = StorageManager.shared,
                        dataAccess: DataAccessor = DataAccessor.instance) {
        var lastImageUrl: String? = nil
        
        self.stopListeningToUser = dataAccess.useUser(id: uid) { user in
            self.bioLabel.text = user.bio
            self.nameLabel.text = user.name
            
            // If something else changes, don't reload the image.
            if user.imageUrl != lastImageUrl {
                storageManger.getImage(imageUrl: user.imageUrl, localFileName: uid) {
                    image in self.onImageLoaded(image: image)
                }
            }
            
            lastImageUrl = user.imageUrl
        }
    }
    
    func onImageLoaded(image: UIImage) {
        profilePic.tintColor = UIColor.clear
        profilePic.setImage(image, for: .normal)
    }
}
