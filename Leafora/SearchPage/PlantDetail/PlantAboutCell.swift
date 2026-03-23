//
//  PlantAboutCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantAboutCell: UICollectionViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // setup
        setupCard()
    }
    
    private func setupCard() {
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
//        contentView.layer.borderColor = UIColor.systemGray4.cgColor
//        contentView.layer.borderWidth = 0.5
//        
    }
    
    func configure(with plant: Plant) {
           descriptionLabel.text = plant.description
       }

}
