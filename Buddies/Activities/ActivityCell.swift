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
    
    @IBAction func goToUserProfile(_ sender: UIButton) {
    }

    @IBOutlet weak var pic1: UIImageView!
    @IBOutlet weak var pic2: UIImageView!
    @IBOutlet weak var pic3: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundUserPictures()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
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
        configureUserImages(images: userImages)
    }
    
    func configureUserImages(images: [UIImage]) {
        if (images.count > 0) {
            pic1.isHidden = false
            pic1.image = images[0]
        }
        if (images.count > 1) {
            pic2.isHidden = false
            pic2.image = images[1]
        }
        if (images.count > 2) {
            pic3.isHidden = false
            pic3.image = images[2]
        }
        if (images.count < 3) {
            pic3.isHidden = true
        }
        if (images.count < 2) {
            pic2.isHidden = true
        }
        if (images.count < 1) {
            pic1.isHidden = true
        }
        
        // hide "..." as needed
        if images.count <= 3{
            extraPicturesLabel.isHidden = true
        } else {
            extraPicturesLabel.isHidden = false
        }
        self.roundUserPictures()
    }

    func roundUserPictures() {
        pic1.makeCircle()
        pic2.makeCircle()
        pic3.makeCircle()
    }
}
