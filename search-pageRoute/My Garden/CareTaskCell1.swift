import UIKit

class CareTaskCell1: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    @IBOutlet var stepsLabelHeightConstraint: NSLayoutConstraint?

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
        
        // Build a visually formatted attributed string
        stepsLabel.attributedText = buildFormattedSteps(from: steps, color: symbolColor, isExpanded: isExpanded)
        
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
                self.cardContainerView.layer.borderColor = UIColor.clear.cgColor
                
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
        let baseColor = getColorForTitle(title)
        let symbolName: String
        switch title.lowercased() {
        case "watering":
            symbolName = "drop.fill"
        case "fertilizing":
            symbolName = "leaf.fill"
        case "repotting":
            symbolName = "arrow.up.bin.fill"
        case "pruning":
            symbolName = "scissors"
        default:
            symbolName = "info.circle.fill"
        }
        return (symbolName, baseColor, baseColor.withAlphaComponent(0.3))
    }
    
    private func getColorForTitle(_ title: String) -> UIColor {
        switch title.lowercased() {
        case "watering":
            return UIColor(red: 0.42, green: 0.71, blue: 0.84, alpha: 1.0)
        case "fertilizing":
            return UIColor(red: 0.52, green: 0.71, blue: 0.42, alpha: 1.0)
        case "repotting":
            return UIColor(red: 0.85, green: 0.65, blue: 0.38, alpha: 1.0)
        case "pruning":
            return UIColor(red: 0.82, green: 0.47, blue: 0.38, alpha: 1.0)
        default:
            return UIColor.systemGray
        }
    }
    
    // MARK: - Formatted Steps Builder
    private func buildFormattedSteps(from raw: String, color: UIColor, isExpanded: Bool) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let lines = raw.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        let textColor: UIColor = isExpanded ? .white : .secondaryLabel
        let scheduleColor: UIColor = isExpanded ? UIColor.white.withAlphaComponent(0.9) : color
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.paragraphSpacing = 4
        
        for (index, line) in lines.enumerated() {
            let cleanLine = line.trimmingCharacters(in: .whitespaces)
            
            if cleanLine.lowercased().hasPrefix("schedule:") {
                // Schedule header line — bold + tinted
                let scheduleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: scheduleColor,
                    .paragraphStyle: paragraphStyle
                ]
                result.append(NSAttributedString(string: cleanLine + "\n\n", attributes: scheduleAttrs))
                
            } else {
                // Any other line (including standard text bullets)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                    .foregroundColor: textColor,
                    .paragraphStyle: paragraphStyle
                ]
                let suffix = (index < lines.count - 1) ? "\n" : ""
                result.append(NSAttributedString(string: cleanLine + suffix, attributes: attrs))
            }
        }
        
        return result
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
