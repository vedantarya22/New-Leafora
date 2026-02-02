//
//  PlantCareCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantCareCell: UICollectionViewCell {
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        setupCard()
       
    }
    
    private var borderLayer: CAShapeLayer?
    

    
    func applyCorners(isFirst: Bool, isLast: Bool) {
        
            contentView.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            contentView.layer.borderColor = UIColor.systemGray4.cgColor
            contentView.layer.borderWidth = 0
            
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        // Handle Masking (Corner Shape)
                if isFirst && isLast {
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else if isFirst {
                    layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top Rounded
                } else if isLast {
                    layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // Bottom Rounded
                } else {
                    layer.cornerRadius = 0 // Middle: Straight
                }
        
        borderLayer?.removeFromSuperlayer()
        
        

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

    
  
    
    func configure(type: String, value: String, isLast: Bool) {

        titleLabel.text = type.capitalized + " :"
        valueLabel.text = value

        switch type.lowercased() {

        case "watering":
            iconImageView.image = UIImage(systemName: "drop.fill")

        case "repotting":
            iconImageView.image = UIImage(systemName: "leaf.fill")

        case "fertilizing":
            iconImageView.image = UIImage(systemName: "aqi.medium")

        case "pruning":
            iconImageView.image = UIImage(systemName: "scissors")

        default:
            iconImageView.image = UIImage(systemName: "circle")
        }
        
        // Hide separator for last cell
           separatorView.isHidden = isLast
    }


}

extension CareCycle {

    var rows: [(type: String, value: String)] {
        [
            ("watering", watering),
            ("repotting", repotting),
            ("fertilizing", fertilizing),
            ("pruning", pruning)
        ]
    }
}
