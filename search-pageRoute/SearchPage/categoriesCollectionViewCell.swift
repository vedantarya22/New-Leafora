//
//  categoriesCollectionViewCell.swift
//  SearchPage
//
//  Created by SDC-USER on 28/01/26.
//

import UIKit

class categoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?

    
    static let identifier = "categoriesCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Round corners for image view if needed
        categoryImageView?.layer.cornerRadius = 8
        categoryImageView?.clipsToBounds = true
        categoryImageView?.contentMode = .scaleAspectFill
//        categoryImageView?.backgroundColor = .systemGray5 // Placeholder color
        //categoryView?.backgroundColor = .systemGray2
        categoryView?.layer.cornerRadius = 16
        categoryView.clipsToBounds = true

    }
    func configure(with category: Category) {
        categoryLabel.text = category.title
        categoryImageView.image = UIImage(named: category.assetName)
        let colors = category.gradient.toUIColor()
        applyGradient(topColor: colors.top, bottomColor: colors.bottom)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = categoryView.bounds
    }

    private func applyGradient(topColor: UIColor, bottomColor: UIColor) {
        gradientLayer?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]

        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = categoryView.bounds
        gradient.cornerRadius = 16

        categoryView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }


}
