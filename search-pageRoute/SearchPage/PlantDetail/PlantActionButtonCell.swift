import UIKit

// Move this outside the class so 'PlantDetailViewController' can see it easily
enum PlantActionType {
    case visualizeAR
}

class PlantActionButtonCell: UICollectionViewCell {
    
    // Ensure this name matches EXACTLY what you connect in the XIB
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupNativeStyle()
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
//        config.baseBackgroundColor = .systemGreen
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
