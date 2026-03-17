import UIKit

// Move this outside the class so 'PlantDetailViewController' can see it easily
enum PlantActionType {
    case visualizeAR
}

class PlantActionButtonCell: UICollectionViewCell {
    
    // Ensure this name matches EXACTLY what you connect in the XIB
    @IBOutlet weak var actionButton: UIButton!
    var onTap: (() -> Void)?

    override func awakeFromNib() {
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        super.awakeFromNib()
        setupNativeStyle()
    }
    
    @objc private func buttonTapped() {
            onTap?()
        }

    func configure(type: PlantActionType) {
        // Keep the text concise and native
        actionButton.setTitle("Visualize in AR View", for: .normal)
    }

    private func setupNativeStyle() {
        // iOS 15+ Native Configuration
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule // Pill shape is modern iOS standard
        config.baseBackgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        config.baseForegroundColor = .white
        
        // Add the SF Symbol icon
        config.image = UIImage(systemName: "viewfinder.circle.fill")
        config.imagePadding = 2
        
        actionButton.configuration = config
        
        // Set a fixed height so it isn't "big ass"
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
