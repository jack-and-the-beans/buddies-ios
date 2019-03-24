import UIKit

class TopicCell: UICollectionViewCell {
  
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var toggleButton: ToggleButton!
    @IBOutlet weak var bottomArea: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = ControlColors.cornerRadius
        bottomArea.layer.cornerRadius = ControlColors.cornerRadius
        // Put the image on top of the bottom area:
        imageView.layer.zPosition = 2
        bottomArea.layer.zPosition = 1
        // Add the border to the bottom:
        bottomArea.layer.borderColor = ControlColors.theme.cgColor
        bottomArea.layer.borderWidth = 1
        nameLabel.textColor = ControlColors.theme
    }
  
    var topic: Topic? {
        didSet {
            if let topic = topic {
                imageView.image = topic.image ?? UIImage()
                nameLabel.text = topic.name
            }
        }
    }
  
}
