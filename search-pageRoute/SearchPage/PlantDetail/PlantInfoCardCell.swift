import UIKit

class PlantInfoCardCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        containerView.backgroundColor = .white
            
            // 2. Pronounced Corner Radius
            containerView.layer.cornerRadius = 20
            
            // 3. Shadow Settings (The "Home Screen" look)
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize(width: 0, height: 10) // Pushes shadow down
            containerView.layer.shadowRadius = 12                          // Makes it soft/spread
            containerView.layer.shadowOpacity = 0.08                       // Depth intensity
            
            // 4. Critical Performance/Visibility Settings
            containerView.layer.masksToBounds = false  // Shadow will NOT show if this is true
        titleLabel.textColor = .black
                descriptionLabel.textColor = .black
            self.clipsToBounds = false
    }

    func configure(title: String, text: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        descriptionLabel.text = text
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
    }
}
