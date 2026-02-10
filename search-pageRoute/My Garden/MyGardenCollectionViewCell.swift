//
//  myGardenCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class MyGardenCollectionViewCell: UICollectionViewCell {
    
    
    
    
    
    @IBOutlet weak var siteNameLabel: UILabel!
    
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var plantCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
    }
   
    
}
