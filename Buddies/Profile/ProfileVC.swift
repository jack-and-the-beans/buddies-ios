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
        
        stopListeningToUser = stopListeningToUser ?? loadProfileData()
    }
    
    deinit {
        stopListeningToUser?()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }
    
    func loadProfileData(uid: String = Auth.auth().currentUser!.uid,
                        storageManger: StorageManager = StorageManager.shared,
                        dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        var lastImageUrl: String? = nil
        
        return dataAccess.useUser(id: uid) { usr in
            guard let user = usr else { return }
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
