//
//  addplantbuttonCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class PlantSiteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plantSiteButton: UIButton!
    @IBOutlet weak var plantSiteLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        plantSiteButton.clipsToBounds = true
        plantSiteButton.layer.cornerRadius = plantSiteButton.frame.width / 2
        
        plantSiteButton.isUserInteractionEnabled = false
        plantSiteLabel.textAlignment = .center
        
        // Default: white background, brandGreen icon
        setDeselectedAppearance()
    }
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut) {
                if self.isSelected {
                    self.setSelectedAppearance()
                } else {
                    self.setDeselectedAppearance()
                }
            }
        }
    }
    
    
    func setSelectedAppearance() {
        // Selected: brandGreen background, white SF symbol
        plantSiteButton.backgroundColor = .brandGreen
        plantSiteButton.tintColor = .white
    }
    
    func setDeselectedAppearance() {
        // Default: white background, brandGreen SF symbol
        plantSiteButton.backgroundColor = .white
        plantSiteButton.tintColor = .brandGreen
        
        layer.borderWidth = 0
    }
    
    func animateSelection() {
        UISelectionFeedbackGenerator().selectionChanged()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.plantSiteButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.plantSiteButton.transform = .identity
            }
        }
    }
}

