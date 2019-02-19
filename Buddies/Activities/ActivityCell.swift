//
//  ActivityCell.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var extraPicturesLabel: UILabel!
    
    @IBOutlet var memberPics:[UIButton]!
    
    
    @IBAction func goToUserProfile(_ sender: UIButton) {
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for memberPic in memberPics{
            memberPic.imageView?.layer.cornerRadius = memberPic.bounds.size.width / 2
            memberPic.imageView?.clipsToBounds = true
        }
    }
}
