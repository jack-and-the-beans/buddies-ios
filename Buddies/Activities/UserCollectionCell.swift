//
//  UserCollectionCell.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class UserCollectionCell: UICollectionViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func onRemoveUser(_ sender: UIButton) {
        print("CLICKED REMOVE USER")
    }
    func render(withUser user: User, shouldRemoveUser: Bool) {
        userName.text = user.name
        if (!shouldRemoveUser) {
            removeButton.removeFromSuperview()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
