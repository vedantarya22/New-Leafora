import UIKit

class PlantRepotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var optionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPlantAppStyle()
    }
    
    private func setupPlantAppStyle() {
        // 1. Creative Card Look
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 24 // Softer, more organic corners
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor.systemGray6.cgColor
        
        // 2. Button as a passive Label
        optionBtn.isUserInteractionEnabled = false
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .brandGreen
        config.titleAlignment = .center
        optionBtn.configuration = config
        
        // 3. Shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.05
        layer.masksToBounds = false
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isSelected {
                    // Selection Style: Solid brandGreen background with white text
                    self.contentView.backgroundColor = .brandGreen
                    self.contentView.layer.borderColor = UIColor.clear.cgColor
                    self.optionBtn.configuration?.baseForegroundColor = .white
                    self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98) // "Pressed" look
                } else {
                    // Default Style: White background with brandGreen text
                    self.contentView.backgroundColor = .white
                    self.contentView.layer.borderColor = UIColor.systemGray6.cgColor
                    self.optionBtn.configuration?.baseForegroundColor = .brandGreen
                    self.transform = .identity
                }
            }
        }
    }
    
    func animateSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    func configure(with title: String) {
        optionBtn.setTitle(title, for: .normal)
    }
}
