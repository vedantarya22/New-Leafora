//
//  PlantSoilCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantSoilCell: UICollectionViewCell {

    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var plantSoilView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
        
       
    }
    
    func applyCorners(isFirst: Bool, isLast: Bool) {
        
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.masksToBounds = true

        if isFirst && isLast {
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        else if isFirst {
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        }
        else if isLast {
            layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        else {
            layer.cornerRadius = 0
        }
    }

    
 
    
    func configure(value:String,isLast : Bool){
        valueLabel.text = value
        // Hide separator for last cell
           separatorView.isHidden = isLast
    }

}

extension SoilType {

    var values: [String] {
        [
            characteristics,
            soilUsed
        ]
    }
}
