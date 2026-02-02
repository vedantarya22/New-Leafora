//
//  CareTaskCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class CareTaskCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .white
                
                // Optional: This helps the corner rounding look cleaner
                self.layer.masksToBounds = true
    }

}
