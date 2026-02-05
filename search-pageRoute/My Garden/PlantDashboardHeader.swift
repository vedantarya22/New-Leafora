import UIKit

class PlantDashboardHeader: UICollectionReusableView {
    
    // MARK: - Outlets
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    // Quick info outlets
    @IBOutlet weak var sunlightValueLabel: UILabel!
    @IBOutlet weak var wateringValueLabel: UILabel!
    @IBOutlet weak var windValueLabel: UILabel!
    
    // Callback for back button
    var onBackTapped: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackButton()
        applyGradientToOverlay()
    }
    
    // MARK: - Setup
    private func setupBackButton() {
        // Create chevron.left SF Symbol for back button
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func applyGradientToOverlay() {
        // Find the gradient overlay view
        for subview in self.subviews {
            if subview.accessibilityLabel == nil && subview.backgroundColor == UIColor(white: 0, alpha: 0) {
                // Apply gradient from top (transparent) to middle (semi-dark)
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = subview.bounds
                gradientLayer.colors = [
                    UIColor.black.withAlphaComponent(0.4).cgColor,
                    UIColor.clear.cgColor
                ]
                gradientLayer.locations = [0.0, 0.5]
                subview.layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }
    
    @objc private func backButtonTapped() {
        onBackTapped?()
    }
    
    // MARK: - Configuration
    func configure(
        with name: String,
        variety: String,
        imageName: String,
        sunlight: String = "Partial",
        watering: String = "2 Days",
        wind: String = "Low"
    ) {
        nameLabel.text = name
        varietyLabel.text = variety
        heroImageView.image = UIImage(named: imageName)
        
        // Configure quick info
        sunlightValueLabel.text = sunlight
        wateringValueLabel.text = watering
        windValueLabel.text = wind
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame when view size changes
        for subview in self.subviews {
            if let gradientLayer = subview.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = subview.bounds
            }
        }
    }
}
