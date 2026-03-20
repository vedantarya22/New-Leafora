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
        // setup
            setupDesign()
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
        // image from local asset
       
               plantImageView.image = UIImage(named: plant.imageName)
        

       }

}
