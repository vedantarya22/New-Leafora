//
//  InsightCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class InsightCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 20
            self.contentView.layer.cornerRadius = 20
            self.contentView.layer.masksToBounds = true // Clips the light green background
            
            // 2. Light "Whisper" Shadow (Same as Care Tasks)
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = 10
            self.layer.shadowOpacity = 0.04
            self.layer.masksToBounds = false // Allows the shadow to spread outside
            
            // 3. Performance Optimization
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
        }
}
