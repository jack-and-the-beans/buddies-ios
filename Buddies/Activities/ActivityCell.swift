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
    }
    
    func format(using activity: Activity) {
        titleLabel.text = activity.title
        descriptionLabel.text = activity.description
        locationLabel.text = activity.locationText
        
        let dateRange = DateInterval(start: activity.startTime.dateValue(),
                                     end: activity.endTime.dateValue())
        
        
        let pixelsPerChar: CGFloat = 10.0
        
        let charsFitInCell = Int(frame.width/pixelsPerChar)
        
        let locStrLength = max(15, charsFitInCell - activity.title.count)
        
        let locStr = dateRange.rangePhrase(relativeTo: Date(), tryShorteningIfLongerThan: locStrLength)
        
        dateLabel.text = locStr.capitalized
        
        let userImages = activity.users.compactMap { $0.image }
        zip(memberPics, userImages).forEach() { (btn, img) in
            btn.setImage(img, for: .normal)
        }
        
        
        // hide "..." as needed
        if userImages.count <= 3{
            extraPicturesLabel.isHidden = true
        } else {
            extraPicturesLabel.isHidden = false
        }
        
        for memberPic in memberPics{
            memberPic.imageView?.layer.cornerRadius = memberPic.bounds.size.width / 2
            memberPic.imageView?.clipsToBounds = true
        }
    }
}
