//
//  PlantTitleCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantTitleCell: UICollectionViewCell {
    
    
    @IBOutlet weak var plantNameLabel: UILabel!
    
    @IBOutlet weak var scientificNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with plant: Plant) {
           plantNameLabel.text = plant.plantName
           scientificNameLabel.text = plant.scientificName
       }

}
