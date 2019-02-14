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
    @IBOutlet weak var picture1: UIButton!
    
    @IBOutlet weak var picture2: UIButton!
    
    @IBOutlet weak var picture3: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        picture1.layer.cornerRadius = picture1.frame.size.width / 2
        picture2.layer.cornerRadius = picture2.frame.size.width / 2
        picture3.layer.cornerRadius = picture2.frame.size.width / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
