//
//  CareTaskCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class CareTaskCell: UICollectionViewCell {

   
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var taskIconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Cell Styling
        self.layer.cornerRadius = 16
        self.contentView.layer.cornerRadius = 16
        self.contentView.layer.masksToBounds = true
        
        // 2. Shadow Settings
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.04
        self.layer.masksToBounds = false
        
        // 3. Performance Optimization
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 16).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = self.traitCollection.displayScale
    }
    
    func configure(title: String, count: Int, color: UIColor) {
        titleLabel.text = title
        unitLabel.text = "\(count) pending"
        
        // Symbols aligned to PlantDetailVC
        switch title {
        case "Watering":
            taskIconImageView.image = UIImage(systemName: "drop.fill")
            taskIconImageView.tintColor = color
        case "Pruning":
            taskIconImageView.image = UIImage(systemName: "scissors")
            taskIconImageView.tintColor = color
        case "Fertilizing":
            taskIconImageView.image = UIImage(systemName: "leaf.fill")
            taskIconImageView.tintColor = color
        case "Repotting":
            taskIconImageView.image = UIImage(systemName: "arrow.up.bin.fill")
            taskIconImageView.tintColor = color
        default:
            taskIconImageView.image = UIImage(systemName: "circle")
            taskIconImageView.tintColor = .black
        }
    }

}
