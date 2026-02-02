//
//  Add_plant_lightCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class Add_plant_lightCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plantLightButton : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGlassBackground()
        styleButton()
        
        plantLightButton.isUserInteractionEnabled = false
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
    
    private func setupGlassBackground() {
        // Simulated glass look without blur glow
        plantLightButton.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.6)
        
        // Rounded design
        plantLightButton.layer.cornerRadius = 30
        plantLightButton.clipsToBounds = true
        
        
    }
    
    
    // MARK: - Typography + Layout
    private func styleButton() {
        plantLightButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        plantLightButton.setTitleColor(.label, for: .normal)
        
        // Center the text cleanly
        plantLightButton.contentHorizontalAlignment = .center
        
        // Remove any shadow coming from the cell
        contentView.layer.shadowOpacity = 0
        layer.shadowOpacity = 0
    }
    
    // MARK: - Configure Cell
    func configure(with title: String) {
        plantLightButton.setTitle(title, for: .normal)
    }
    
    
    func setSelectedAppearance() {
        plantLightButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        plantLightButton.tintColor = .systemGreen
    }
    
    func setDeselectedAppearance() {
        plantLightButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        plantLightButton.tintColor = .black
        layer.borderWidth = 0
    }
    
    func animateSelection() {
        UIView.animate(withDuration: 0.1, animations: {
            self.plantLightButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.plantLightButton.transform = .identity
            }
        }
    }
    
}
