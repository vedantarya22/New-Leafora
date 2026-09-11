import UIKit

// keep enum outside for shared access
enum PlantActionType {
    case visualizeAR
}

class PlantActionButtonCell: UICollectionViewCell {
    
    // should match xib outlet name
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
        // concise button title
        actionButton.setTitle("Visualize in AR View", for: .normal)
    }

    private func setupNativeStyle() {
        // iOS 15+ button config
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule // pill style
        config.baseBackgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        config.baseForegroundColor = .white
        
        // SF symbol icon
        config.image = UIImage(systemName: "viewfinder.circle.fill")
        config.imagePadding = 2
        
        actionButton.configuration = config
        
        // fixed height
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
