import UIKit
import SDWebImage

class SiteDetailCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    // Connect this to the white UIView you added in Step 2!
    @IBOutlet weak var cardBackgroundView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // CARD STYLING (White Box)
              cardBackgroundView.layer.cornerRadius = 20
              cardBackgroundView.backgroundColor = .white
              
              // Shadow
              self.clipsToBounds = false
              cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
              cardBackgroundView.layer.shadowOpacity = 0.08
              cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
              cardBackgroundView.layer.shadowRadius = 8
              
              // IMAGE STYLING
              plantImageView.layer.cornerRadius = 16
              plantImageView.clipsToBounds = true
              plantImageView.contentMode = .scaleAspectFill
              plantImageView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    }

    func configure(userPlant: UserPlant) {
            // Load plant data from JSON using plantId
            let allPlants = PlantCatalogueCache.shared.plants
            let plant = allPlants.first(where: { $0.plantId == userPlant.plantId })
            
            // Set plant name
            nameLabel.text = plant?.plantName ?? "Unknown Plant"
            
            // PRIORITY 1: Use user-uploaded image if available (local cache)
            if let imageData = userPlant.imageData,
               let userImage = UIImage(data: imageData) {
                plantImageView.image = userImage
                print("✅ Using user-uploaded image for:", plant?.plantName ?? "plant")
            }
            // PRIORITY 2: Fall back to Cloudinary URL (remote)
            else if let urlString = userPlant.imageUrl,
                    let url = URL(string: urlString) {
                plantImageView.sd_setImage(
                    with: url,
                    placeholderImage: UIImage(systemName: "leaf.fill"),
                    options: [.retryFailed, .scaleDownLargeImages]
                )
                print("🌐 Loading Cloudinary image for:", plant?.plantName ?? "plant")
            }
            // PRIORITY 3: Fall back to default plant catalogue image
            else if let plant = plant {
                plantImageView.image = UIImage(named: plant.imageName)
                print("📁 Using default catalogue image for:", plant.plantName)
            }
            // PRIORITY 4: Placeholder if no image available
            else {
                let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
                plantImageView.image = UIImage(systemName: "leaf.fill", withConfiguration: config)
                plantImageView.tintColor = .systemGray3
                print("⚠️ No image available, using placeholder")
            }
            
            // Optional: Show quantity badge if > 1
            if userPlant.quantity > 1 {
                nameLabel.text = "\(plant?.plantName ?? "Unknown") (×\(userPlant.quantity))"
            }
        }
        
}
