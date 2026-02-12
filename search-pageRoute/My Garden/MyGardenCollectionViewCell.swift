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
    
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        setupGradient()
        setupDecorativeCircle()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Use the size provided by the flow layout delegate
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        
        // Round the decorative circle
        if let leafCircle = contentView.viewWithTag(999) {
            leafCircle.layer.cornerRadius = leafCircle.bounds.width / 2
        }
    }
    
    private func setupGradient() {
        // Remove existing gradient if any
        gradientLayer?.removeFromSuperlayer()
        
        // Create gradient layer
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        
        // Create a nice gradient from lighter green (top-left) to darker green (bottom-right)
        let topColor = UIColor(red: 0.30, green: 0.65, blue: 0.40, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.20, green: 0.50, blue: 0.30, alpha: 1.0).cgColor
        
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        // Insert gradient at the back
        contentView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    private func setupDecorativeCircle() {
        // Find and round the decorative circle view
        if let leafCircle = contentView.viewWithTag(999) {
            leafCircle.layer.cornerRadius = 40 // Half of 80
            leafCircle.clipsToBounds = true
        }
    }
}
