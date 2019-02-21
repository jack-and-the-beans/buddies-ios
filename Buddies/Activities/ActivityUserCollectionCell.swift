//
//  ActivityUserCollectionCell.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityUserCollectionCell: UICollectionViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func onRemoveUser(_ sender: UIButton) {
        print("CLICKED REMOVE USER")
    }

    func render(withUser user: User, isCurUserOwner: Bool, isIndividualOwner: Bool) {
        userName.text = user.name
        if (isIndividualOwner) {
            userName.text?.append(" (owner)")
        }
        if (!isCurUserOwner) {
            removeButton?.removeFromSuperview()
        }
        userImage.image = user.image
        userImage.makeCircle()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
