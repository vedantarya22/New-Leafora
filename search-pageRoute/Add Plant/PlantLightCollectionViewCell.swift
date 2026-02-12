import UIKit

class PlantLightCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plantLightButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCreativeUI()
    }
    
    private func setupCreativeUI() {
        // 1. The Card Look: Use System colors for a native feel
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        // 2. Subtle Border (Modern iOS style)
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        
        // 3. Button Passthrough: Make the button a visual element only
        plantLightButton.isUserInteractionEnabled = false
        plantLightButton.configuration = .plain() // Remove default gray/blue styles
        plantLightButton.tintColor = .label
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                if self.isSelected {
                    // Plant Theme: Soft Green background + Dark Green border
                    self.contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
                    self.contentView.layer.borderColor = UIColor.systemGreen.cgColor
                    self.plantLightButton.tintColor = .systemGreen
                } else {
                    self.contentView.backgroundColor = .secondarySystemGroupedBackground
                    self.contentView.layer.borderColor = UIColor.systemGray6.cgColor
                    self.plantLightButton.tintColor = .label
                }
            }
        }
    }
    
    func animateSelection() {
        // Haptic feedback for a premium feel
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
