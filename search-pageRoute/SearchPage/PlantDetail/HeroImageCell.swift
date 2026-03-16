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
        plantImageView.layer.cornerRadius = 20
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(with plant: Plant) {
        // Set image from asset catalog or bundle
       
               plantImageView.image = UIImage(named: plant.imageName)
        

       }

}
