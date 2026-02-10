import UIKit

class BenefitsCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var benefitsTextLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    
    var onToggle: (() -> Void)?
    private var fullText: String = ""
    private var isExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        iconImageView.isHidden = true
    }
    
    private func setupUI() {
        // Container styling
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        containerView.backgroundColor = .secondarySystemGroupedBackground
        
        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.masksToBounds = false
        
        // Icon setup
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconImageView.image = UIImage(systemName: "sparkles", withConfiguration: config)
        iconImageView.tintColor = .systemPurple
        iconImageView.contentMode = .scaleAspectFit
        
        // Text label
        benefitsTextLabel.numberOfLines = 0
        benefitsTextLabel.font = .systemFont(ofSize: 15, weight: .regular)
        benefitsTextLabel.textColor = .label
        
        // Button styling
        showMoreButton.setTitleColor(.systemGreen, for: .normal)
        showMoreButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        showMoreButton.addTarget(self, action: #selector(toggleExpansion), for: .touchUpInside)
    }
    
    func configure(text: String, isExpanded: Bool) {
        self.fullText = text
        self.isExpanded = isExpanded
        
        if isExpanded {
            // Show full text
            benefitsTextLabel.text = text
            benefitsTextLabel.numberOfLines = 0
            showMoreButton.setTitle("Show Less", for: .normal)
            
            // Animate button icon
//            UIView.animate(withDuration: 0.3) {
//                self.showMoreButton.transform = CGAffineTransform(rotationAngle: .pi)
//            }
        } else {
            // Show truncated text (first 2 lines)
            benefitsTextLabel.text = text
            benefitsTextLabel.numberOfLines = 3
            showMoreButton.setTitle("Show More", for: .normal)
            
            // Reset button rotation
            UIView.animate(withDuration: 0.3) {
                self.showMoreButton.transform = .identity
            }
        }
        
        layoutIfNeeded()
    }
    
    @objc private func toggleExpansion() {
        onToggle?()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        var newFrame = layoutAttributes.frame
        newFrame.size.height = ceil(size.height)
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
