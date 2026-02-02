//
//  HeroImageCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class HeroImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var plantImageView: UIImageView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


            setupDesign()
//
    }
    
    
    private func setupDesign() {
            // 1. Corner Radius
            // A value of 24-30 looks very modern for Hero images
            plantImageView.layer.cornerRadius = 16
            
            // 2. Crucial for "Cut" edges
            // .scaleAspectFill ensures the image covers the whole space without distorting.
            // clipsToBounds = true cuts off the excess parts cleanly at the rounded corners.
            plantImageView.contentMode = .scaleAspectFill
            plantImageView.clipsToBounds = true
            
            // 3. (Optional) Border
            // A very subtle border can define the edges if the image is white/bright
            plantImageView.layer.borderWidth = 0.5
            plantImageView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    
    func configure(with plant: Plant) {
        // Set image from asset catalog or bundle
       
               plantImageView.image = UIImage(named: plant.imageName)
        

       }

}
