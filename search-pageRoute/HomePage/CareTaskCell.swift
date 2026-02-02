//
//  CareTaskCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class CareTaskCell: UICollectionViewCell {

   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 20
            self.contentView.layer.cornerRadius = 20
            self.contentView.layer.masksToBounds = true
            
            // 2. Shadow Settings
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2) // Move shadow down slightly
            self.layer.shadowRadius = 10                          // Make it "fuzzy/soft"
            self.layer.shadowOpacity = 0.04                      // Keep it very light (10%)
            self.layer.masksToBounds = false                      // Essential for shadows!
            
            // 3. Performance Optimization
            // This tells iOS to cache the shadow shape so it doesn't lag while scrolling
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
    }

}
