//
//  MemoryCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class MemoryCell: UICollectionViewCell {
//    @IBOutlet weak var plusIcon: UIButton!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. Make the card look like a premium paper
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = false // Allows shadow to show
        
        // 2. Stronger, cleaner shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius = 10
        
        // 3. Label styling
        dateLabel.font = .systemFont(ofSize: 12, weight: .bold)
        dateLabel.textColor = .secondaryLabel
    }
    override func prepareForReuse() {
            super.prepareForReuse()
            // Reset state so recycled cells don't show the wrong thing
            imageView.image = nil
           
        }

}
