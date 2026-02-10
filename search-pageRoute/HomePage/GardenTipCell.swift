//
//  GardenTipCell.swift
//  homescreen1
//
//  Created by SDC-USER on 10/02/26.
//

import UIKit

class GardenTipCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipMessageLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Container styling
//        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        
        // Shadow for the cell
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.08
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 20
        
        // Performance optimization
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        // Icon styling
//        iconLabel.font = .systemFont(ofSize: 16)
        
        // Title styling
//        tipTitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        /*tipTitleLabel.textColor = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)*/ // Sage green
        
        // Message styling
//        tipMessageLabel.font = .systemFont(ofSize: 16, weight: .semibold)
//        tipMessageLabel.textColor = UIColor(red: 0.1, green: 0.18, blue: 0.1, alpha: 1.0) // Dark green
//        tipMessageLabel.numberOfLines = 0
//        
//        // Image view styling
//        plantImageView.contentMode = .scaleAspectFill
//        plantImageView.clipsToBounds = true
        plantImageView.layer.cornerRadius = 8
    }
    
    func configure(tip: GardenTip) {
//        iconLabel.text = tip.icon
        tipTitleLabel.text = tip.title
        tipMessageLabel.text = tip.message
        
        // Set the plant image if available
        if let imageName = tip.imageName {
            plantImageView.image = UIImage(named: imageName)
        } else {
            // Default placeholder image
            plantImageView.image = UIImage(systemName: "leaf.fill")
            plantImageView.tintColor = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
        }
    }
}

// MARK: - Garden Tip Model
struct GardenTip {
    let icon: String        // Emoji like "🌱"
    let title: String       // "Garden Tip"
    let message: String     // The actual tip text
    let imageName: String?  // Optional image asset name
    
    static func randomTip() -> GardenTip {
        let tips = [
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Water your succulents when soil is fully dry",
                imageName: "mytip"
            ),
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Morning watering prevents fungal diseases",
                imageName: "mytip"
            ),
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Most houseplants prefer indirect sunlight",
                imageName: "mytip"
            ),
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Prune dead leaves to encourage new growth",
                imageName: "mytip"
            ),
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Repot when roots grow through drainage holes",
                imageName: "mytip"
            ),
            GardenTip(
                icon: "",
                title: "Garden Tip",
                message: "Group plants with similar water needs together",
                imageName: "mytip"
            )
        ]
        return tips.randomElement() ?? tips[0]
    }
}
