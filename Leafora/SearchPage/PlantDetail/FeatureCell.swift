//
//  FeatureCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class FeatureCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // setup
        setupCard()
    }
    
    private func setupCard() {
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
        
    }
    
    func configure(type: FeatureType, plant: Plant) {

           switch type {

           case .light:
               iconImageView.image = UIImage(systemName: "sun.max.fill")
               titleLabel.text = plant.lightRequirement.displayName

           case .petFriendly:
               iconImageView.image = UIImage(systemName: "pawprint.fill")
               titleLabel.text = plant.petFriendly ? "Pet Friendly" : "Not Pet Friendly"

           case .toxic:
               iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
               titleLabel.text = plant.toxic ? "Non Toxic" : "Toxic"
           }
       }
    

}
