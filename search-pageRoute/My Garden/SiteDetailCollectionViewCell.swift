import UIKit

class SiteDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cardBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Create the soft shadow look from your screenshot
        cardBackgroundView.layer.cornerRadius = 18
        cardBackgroundView.backgroundColor = .white
        
        self.clipsToBounds = false
        cardBackgroundView.layer.masksToBounds = false
        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.08
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardBackgroundView.layer.shadowRadius = 8
        
        plantImageView.layer.cornerRadius = 12
        plantImageView.clipsToBounds = true
    }

    func configure(userPlant: UserPlant) {
        // Use plantId and clean it up for the title
        let displayName = userPlant.plantId.replacingOccurrences(of: "_", with: " ").capitalized
        nameLabel.text = displayName
        
        if let data = userPlant.imageData {
            plantImageView.image = UIImage(data: data)
        } else {
            // Default icon if JSON image is nil
            plantImageView.image = UIImage(systemName: "leaf.fill")
            plantImageView.tintColor = .systemGreen
        }
    }
}
