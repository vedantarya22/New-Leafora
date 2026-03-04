import UIKit

class SearchPageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SearchPageCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var plantLabel: UILabel!
    @IBOutlet weak var scientificLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    
    private func setupStyle() {
        containerView?.layer.cornerRadius = 20
        plantImageView.layer.cornerRadius = 16
        plantImageView.clipsToBounds = true
        
        [difficultyLabel, lightLabel].forEach { label in
            label?.layer.cornerRadius = 10
            label?.layer.masksToBounds = true
            label?.textAlignment = .center
        }
    }
    
    // MARK: - Tag Mapping
    private func tagStyle(for tag: String) -> (background: UIColor, text: UIColor) {
        switch tag.lowercased() {
        case "medicinal":           return (.systemRed, .white)
        case "air purifying":       return (.systemCyan, .white)
        case "pet friendly":        return (.systemGreen, .white)
        case "low maintenance":     return (.systemOrange, .white)
        case "vastu friendly":      return (UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 1), .white)
        case "edible":              return (.systemBrown, .white)
        case "indoor":              return (.systemIndigo, .white)
        case "outdoor":             return (.systemYellow, .black)
        case "drought tolerant":    return (UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1), .white)
        case "fast growing":        return (.systemMint, .white)
        default:                    return (.systemGray, .white)
        }
    }

    private func applyTag(_ label: UILabel, tag: String) {
        let style = tagStyle(for: tag)
        
        // Small colored dot + tag text, no background
        let dot = NSAttributedString(
            string: "● ",
            attributes: [
                .foregroundColor: style.background,
                .font: UIFont.systemFont(ofSize: 9, weight: .bold)
            ]
        )
        let text = NSAttributedString(
            string: tag.capitalized,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: UIFont.systemFont(ofSize: 12, weight: .medium)
            ]
        )
        
        let combined = NSMutableAttributedString()
        combined.append(dot)
        combined.append(text)
        
        label.attributedText = combined
        label.backgroundColor = .clear
        label.layer.cornerRadius = 0
        label.layer.masksToBounds = false
    }

    // MARK: - Configure with Plant
    func configure(with plant: Plant) {
        plantLabel.text = plant.plantName
        scientificLabel.text = plant.scientificName
        plantImageView.image = UIImage(named: plant.imageName)
        
        applyTag(difficultyLabel, tag: plant.tags.indices.contains(0) ? plant.tags[0] : "-")
        applyTag(lightLabel, tag: plant.tags.indices.contains(1) ? plant.tags[1] : "-")
    }

    // MARK: - Configure with UserPlant
    func configure(userPlant: UserPlant) {
        let allPlants = JSONLoader.loadPlants(from: "plantData")
        guard let plant = allPlants.first(where: { $0.plantId == userPlant.plantId }) else {
            plantLabel.text = "Unknown Plant"
            scientificLabel.text = ""
            plantImageView.image = UIImage(systemName: "leaf.fill")
            difficultyLabel.text = "-"
            lightLabel.text = "-"
            return
        }
        
        plantLabel.text = plant.plantName
        scientificLabel.text = plant.scientificName
        
        if let imageData = userPlant.imageData, let userImage = UIImage(data: imageData) {
            plantImageView.image = userImage
        } else {
            plantImageView.image = UIImage(named: plant.imageName)
        }
        
        applyTag(difficultyLabel, tag: plant.tags.indices.contains(0) ? plant.tags[0] : "-")
        applyTag(lightLabel, tag: plant.tags.indices.contains(1) ? plant.tags[1] : "-")
    }
}
