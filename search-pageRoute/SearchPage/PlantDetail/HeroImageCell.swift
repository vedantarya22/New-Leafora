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
    
    
    private let gradientOverlay = CAGradientLayer()

    private func setupDesign() {
        plantImageView.layer.cornerRadius = 20
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        
        gradientOverlay.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.15).cgColor
        ]
        gradientOverlay.startPoint = CGPoint(x: 0.5, y: 0.6)
        gradientOverlay.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradientOverlay.cornerRadius = 20
        plantImageView.layer.addSublayer(gradientOverlay)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientOverlay.frame = plantImageView.bounds
    }
    
    func configure(with plant: Plant) {
        // Set image from asset catalog or bundle
       
               plantImageView.image = UIImage(named: plant.imageName)
        

       }

}
