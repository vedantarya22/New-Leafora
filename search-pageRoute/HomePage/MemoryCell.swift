//
//  MemoryCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class MemoryCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addPlaceholderContainer: UIView! // The new container from step 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Unified Styling
        self.layer.cornerRadius = 20
        self.contentView.layer.cornerRadius = 20
        self.contentView.layer.masksToBounds = true
        
        // Soft Shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.04
        self.layer.masksToBounds = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
    }

    func configure(with memory: GardenMemory?, isAddButton: Bool) {
        // Reset state
        self.layer.sublayers?.filter { $0.name == "DashedBorder" }.forEach { $0.removeFromSuperlayer() }
        
        if isAddButton {
            // --- ADD BUTTON STATE ---
            addPlaceholderContainer.isHidden = false
            imageView.image = nil
            imageView.backgroundColor = .systemGray6.withAlphaComponent(0.3) // Very light tint
            dateLabel.isHidden = true
            
            // Draw the dots
            DispatchQueue.main.async {
                self.addDashedBorder(color: .systemGray3)
            }
        } else {
            // --- PHOTO STATE ---
            addPlaceholderContainer.isHidden = true
            imageView.image = memory?.image
            imageView.backgroundColor = .clear
            dateLabel.isHidden = false
            dateLabel.text = "Captured \(formatDate(memory?.timestamp ?? Date()))"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
extension UIView {
    func addDashedBorder(color: UIColor) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [6, 4] // Dash length and gap
        shapeLayer.fillColor = nil
        // We use self.bounds to ensure it fits the card exactly
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
        shapeLayer.name = "DashedBorder"
        
        // Remove existing dashed layers to prevent stacking
        self.layer.sublayers?.filter { $0.name == "DashedBorder" }.forEach { $0.removeFromSuperlayer() }
        self.layer.addSublayer(shapeLayer)
    }
}
