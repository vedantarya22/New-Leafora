//
//  SearchPageCollectionViewCell.swift
//  SearchPage
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class SearchPageCollectionViewCell: UICollectionViewCell {

    static let identifier = "SearchPageCollectionViewCell"

    // MARK: - Outlets
    // Connect these to your XIB elements
    @IBOutlet weak var containerView: UIView! // The white card background
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var plantLabel: UILabel!
    @IBOutlet weak var scientificLabel: UILabel!
    
    // The two colored labels at the bottom
    @IBOutlet weak var difficultyLabelView: UIView!
    @IBOutlet weak var lightLabelView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var lightLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    
    private func setupStyle() {
        // Basic styling for the card
        // Note: Layout constraints are already handled in your XIB
        if let container = containerView {
            container.layer.cornerRadius = 20
//            container.layer.shadowColor = UIColor.black.cgColor
//            container.layer.shadowOpacity = 0.05
//            container.layer.shadowOffset = CGSize(width: 0, height: 4)
//            container.layer.shadowRadius = 6
        }
        
        plantImageView.layer.cornerRadius = 16
        plantImageView.clipsToBounds = true
        
        // Rounding the tag labels
        difficultyLabelView.layer.cornerRadius = 10
        difficultyLabelView.layer.masksToBounds = true
        
        lightLabelView.layer.cornerRadius = 10
        lightLabelView.layer.masksToBounds = true
    }
//    
    // Call this from the ViewController to fill data
    func configure(with plant: Plant) {
        plantLabel.text = plant.plantName
        scientificLabel.text = plant.scientificName
        plantImageView.image = UIImage(named: plant.imageName)
        
        // Optional: Map other fields like difficulty if UI supports it
        difficultyLabel.text = plant.tags[0].capitalized
        lightLabel.text = plant.tags[1].capitalized
    }
}
