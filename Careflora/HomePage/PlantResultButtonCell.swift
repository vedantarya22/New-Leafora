import UIKit

class PlantResultButtonCell: UICollectionViewCell {
    
    @IBOutlet weak var actionButton: UIButton!
    var onTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        setupNativeStyle()
    }
    
    @objc private func buttonTapped() {
        onTap?()
    }
    
    func configure(title: String) {
        actionButton.setTitle(title, for: .normal)
    }
    
    private func setupNativeStyle() {
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        config.baseForegroundColor = .white
        

        config.imagePadding = 2
        
        actionButton.configuration = config
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
