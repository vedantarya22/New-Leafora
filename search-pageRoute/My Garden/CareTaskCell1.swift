import UIKit

class CareTaskCell1: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    @IBOutlet weak var stepsLabelHeightConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Native iOS Card Style - Clean and Minimal
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.cornerCurve = .continuous
        cardContainerView.backgroundColor = .secondarySystemGroupedBackground
        
        // Very subtle native iOS shadow
        cardContainerView.layer.shadowColor = UIColor.black.cgColor
        cardContainerView.layer.shadowOpacity = 0.08
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardContainerView.layer.shadowRadius = 8
        cardContainerView.layer.masksToBounds = false
        
        // Label setup with better fonts
        stepsLabel.numberOfLines = 0
        stepsLabel.lineBreakMode = .byWordWrapping
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        stepsLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
        // Icon setup
        iconImageView.contentMode = .scaleAspectFit
    }

    func configure(icon: String, title: String, steps: String, isExpanded: Bool) {
        guard titleLabel != nil, stepsLabel != nil, iconImageView != nil else { return }

        // Set SF Symbol with color
        let (symbolName, symbolColor, borderColor) = getSymbolForTitle(title)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        iconImageView.image = UIImage(systemName: symbolName, withConfiguration: config)
        
        titleLabel.text = title
        stepsLabel.text = steps
        
        // Get color scheme
        let backgroundColor = getColorForTitle(title)
        
        if isExpanded {
            // === EXPANDED STATE ===
            stepsLabel.isHidden = false
            stepsLabelHeightConstraint?.isActive = false
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                // Colored background when expanded
                self.cardContainerView.backgroundColor = backgroundColor
                
                // Remove border when expanded
                self.cardContainerView.layer.borderWidth = 0
                
                // White text and icon
                self.titleLabel.textColor = .white
                self.stepsLabel.textColor = UIColor.white.withAlphaComponent(0.95)
                self.iconImageView.tintColor = .white
                self.chevronImageView.tintColor = .white
                
                // Rotate chevron
                self.chevronImageView.transform = CGAffineTransform(rotationAngle: .pi)
                
                // Slightly stronger shadow
                self.cardContainerView.layer.shadowOpacity = 0.15
                self.cardContainerView.layer.shadowRadius = 12
                self.cardContainerView.layer.shadowColor = backgroundColor.cgColor
                
                self.layoutIfNeeded()
            }
            
        } else {
            // === COLLAPSED STATE ===
            stepsLabel.isHidden = true
            stepsLabelHeightConstraint?.isActive = true
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                // Light background when collapsed
                self.cardContainerView.backgroundColor = .secondarySystemGroupedBackground
                
                // Add colored left border for distinction
                self.cardContainerView.layer.borderWidth = 2
                self.cardContainerView.layer.borderColor = borderColor.cgColor
                
                // Dark text, colored icon
                self.titleLabel.textColor = .label
                self.stepsLabel.textColor = .secondaryLabel
                self.iconImageView.tintColor = symbolColor
                self.chevronImageView.tintColor = .tertiaryLabel
                
                // Reset chevron
                self.chevronImageView.transform = .identity
                
                // Normal shadow
                self.cardContainerView.layer.shadowOpacity = 0.08
                self.cardContainerView.layer.shadowRadius = 8
                self.cardContainerView.layer.shadowColor = UIColor.black.cgColor
                
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - SF Symbols & Colors
    private func getSymbolForTitle(_ title: String) -> (symbol: String, color: UIColor, borderColor: UIColor) {
        switch title.lowercased() {
        case "watering":
            return ("drop.fill", UIColor.systemBlue, UIColor.systemBlue.withAlphaComponent(0.3))
        case "fertilizing":
            return ("leaf.fill", UIColor.systemGreen, UIColor.systemGreen.withAlphaComponent(0.3))
        case "repotting":
            return ("arrow.triangle.2.circlepath", UIColor.systemOrange, UIColor.systemOrange.withAlphaComponent(0.3))
        default:
            return ("info.circle.fill", UIColor.systemPurple, UIColor.systemPurple.withAlphaComponent(0.3))
        }
    }
    
    private func getColorForTitle(_ title: String) -> UIColor {
        switch title.lowercased() {
        case "watering":
            return UIColor.systemBlue
        case "fertilizing":
            return UIColor.systemGreen
        case "repotting":
            return UIColor.systemOrange
        default:
            return UIColor.systemIndigo
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
