import UIKit

class PlantInfoCardCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.systemGray6.cgColor
        containerView.backgroundColor = .systemBackground
    }

    func configure(title: String, text: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        descriptionLabel.text = text
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
    }
}
