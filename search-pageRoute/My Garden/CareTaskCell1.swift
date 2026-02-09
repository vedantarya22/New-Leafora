//
//  CareTaskCell.swift
//  PlantApp
//
//  Created by AI Assistant on 05/02/26.
//

import UIKit

class CareTaskCell1: UICollectionViewCell {
    
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Card shadow
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.06
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardContainer.layer.shadowRadius = 8
        cardContainer.layer.masksToBounds = false
    }
    
    func configure(icon: String, taskName: String, status: CareStatus) {
        iconLabel.text = icon
        taskNameLabel.text = taskName
        statusLabel.text = status.text
        statusLabel.textColor = status.color
    }
}
