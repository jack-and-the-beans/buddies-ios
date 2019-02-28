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
    
    func loadProfileData(storageManger: StorageManager = StorageManager.shared,
                          dataAccess: DataAccessor = DataAccessor.instance) -> Canceler {
        return dataAccess.useLoggedInUser { user in
            guard let user = user else { return }
            
            self.bioLabel.text = user.bio
            self.nameLabel.text = user.name
            
            // If something else changes, don't reload the image.
            if let image = user.image {
                self.onImageLoaded(image: image)
            }
        }
    }
    
    func onImageLoaded(image: UIImage) {
        profilePic.tintColor = UIColor.clear
        profilePic.setImage(image, for: .normal)
    }
}
