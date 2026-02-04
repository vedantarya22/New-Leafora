import UIKit

class PlantInfoCardCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        
        // Shadow for the "Home Screen" look
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 12
        containerView.layer.shadowOpacity = 0.12
        containerView.layer.masksToBounds = false
        
        titleLabel.textColor = .black
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
    }

    // VERSION A: For standard cards (Care Cycle, Soil, etc.)
    func configure(title: String, text: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        descriptionLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: UIColor.black]
        )
    }

    // VERSION B: For the Merged "About & Info" card
    func configure(title: String, plant: Plant) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: "info.circle.fill")
        iconImageView.tintColor = .systemBlue
        
        let fullAttributedString = NSMutableAttributedString()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let descAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        fullAttributedString.append(NSAttributedString(string: "\(plant.description)\n\n", attributes: descAttr))

        func appendDetail(icon: String, text: String, color: UIColor) {
            let imageAttachment = NSTextAttachment()
            let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            imageAttachment.image = UIImage(systemName: icon, withConfiguration: config)?.withTintColor(color)
            imageAttachment.bounds = CGRect(x: 0, y: -2, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
            
            fullAttributedString.append(NSAttributedString(attachment: imageAttachment))
            fullAttributedString.append(NSAttributedString(string: "  \(text)\n", attributes: descAttr))
        }

        appendDetail(icon: "sun.max.fill", text: plant.lightRequired, color: .systemYellow)
        appendDetail(icon: "gauge.with.needle.fill", text: "Difficulty: \(plant.careDifficulty.capitalized)", color: .systemGreen)
        
        let petIcon = plant.petFriendly ? "pawprint.fill" : "exclamationmark.shield.fill"
        let petStatus = plant.petFriendly ? "Pet Friendly" : "Toxic to Pets"
        appendDetail(icon: petIcon, text: petStatus, color: plant.petFriendly ? .systemGreen : .systemRed)

        descriptionLabel.attributedText = fullAttributedString
    }
}
