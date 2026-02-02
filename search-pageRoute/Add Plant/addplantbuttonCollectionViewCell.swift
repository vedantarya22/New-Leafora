//
//  addplantbuttonCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class addplantbuttonCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plantSiteButton: UIButton!
    @IBOutlet weak var plantSiteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        plantSiteButton.clipsToBounds = true
        plantSiteButton.layer.cornerRadius = plantSiteButton.frame.width / 2
        
        plantSiteButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        plantSiteLabel.textAlignment = .center
        plantSiteLabel.textColor = .darkGray
        
        plantSiteButton.isUserInteractionEnabled = false
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                setSelectedAppearance()
            } else {
                setDeselectedAppearance()
            }
        }
    }
    
    
    func setSelectedAppearance() {
        plantSiteButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        //               plantSiteButton.tintColor = .systemGreen
        plantSiteLabel.textColor = .darkGray
        
    }
    
    func setDeselectedAppearance() {
        plantSiteButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        plantSiteButton.tintColor = .black
        plantSiteLabel.textColor = .darkGray
        
        layer.borderWidth = 0
    }
    
    func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.plantSiteButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.plantSiteButton.transform = .identity
            }
        }
    }
    
    
    
    
}
