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
    
    private var removeUser: ((_ uid: String) -> Void)?
    private var tapUser: ((_ uid: String) -> Void)?
    
    @IBAction func onRemoveUser(_ sender: UIButton) {
        guard let uid = curUid else { return }
        removeUser?(uid)
    }
    
    @IBAction func onTapUser(_ sender: Any) {
        guard let uid = curUid else { return }
        tapUser?(uid)
    }

    
    private var curUid: String?

    func render(withUser user: User, isCurUserOwner: Bool, isIndividualOwner: Bool, tapUser: ((_ uid: String)->Void)?, removeUser: ((_ uid: String)->Void)?) {
        userName.text = user.name
        curUid = user.uid

        self.removeUser = removeUser
        self.tapUser = tapUser
        if (isIndividualOwner) {
            userName.text?.append(" (owner)")
        }
        if (isCurUserOwner) {
            removeButton?.isHidden = false
        } else {
            removeButton?.isHidden = true
        }
        if (isIndividualOwner && isCurUserOwner) {
            // handle the case where the cur item is the cur user
            removeButton?.isHidden = true
        }
        userImage.image = user.image
        userImage.makeCircle()
        self.removeButton.tintColor = Theme.bad
        self.removeButton.titleLabel?.textColor = Theme.bad
    }
}
