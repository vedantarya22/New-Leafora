//
//  Plant_Q4CollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class PlantRepotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var optionBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupGlassBackground()
        styleButton()
    }
    
    
    private func setupGlassBackground() {
        // Simulated glass look without blur glow
        optionBtn.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)
        
        // Rounded design
        optionBtn.layer.cornerRadius = 30
        optionBtn.clipsToBounds = true
        
        optionBtn.isUserInteractionEnabled = false
    }
    
    private func styleButton() {
        // Simple frosted-light background (no blur halo)
        
        
        optionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        optionBtn.setTitleColor(.label, for: .normal)
        
        // Remove all cell shadows
        contentView.layer.shadowOpacity = 0
        layer.shadowOpacity = 0
        
        
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
        optionBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        
        
    }
    
    
    
    func setDeselectedAppearance() {
        optionBtn.backgroundColor = UIColor(white: 0.95, alpha: 1)
        optionBtn.tintColor = .black
        
        
        layer.borderWidth = 0
    }
    
    func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.optionBtn.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.optionBtn.transform = .identity
            }
        }
    }
    
    
    
    func configure(with title: String) {
        optionBtn.setTitle(title, for: .normal)
    }
    
    
    
}
