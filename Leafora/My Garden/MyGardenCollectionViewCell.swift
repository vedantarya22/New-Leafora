//
//  MyGardenCollectionViewCell.swift
//  PlantApp
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class MyGardenCollectionViewCell: UICollectionViewCell {
    
    // XIB outlets (hidden — all programmatic)
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var plantCountLabel: UILabel!
    
    // MARK: - Programmatic UI
    private let iconCircle = UIView()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let countLabel = UILabel()
    
    private var didSetup = false
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        siteNameLabel?.isHidden = true
        iconButton?.isHidden = true
        plantCountLabel?.isHidden = true
        if let v = contentView.viewWithTag(999) { v.isHidden = true }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSetup { buildUI(); didSetup = true }
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
    }
    
    // MARK: - Build UI (Apple Home App Style)
    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // === Card ===
        contentView.layer.cornerRadius = 20
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .white
        
        // === Subtle Green Outline ===
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor(red: 0.72, green: 0.88, blue: 0.76, alpha: 1.0).cgColor
        
        // === Shadow ===
        layer.cornerRadius = 20
        layer.cornerCurve = .continuous
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.07
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // === Large Centered Icon Circle ===
        // Soft green tinted background — the focal point of the card
        iconCircle.backgroundColor = UIColor(red: 0.85, green: 0.94, blue: 0.87, alpha: 1.0)
        iconCircle.layer.cornerRadius = 22
        iconCircle.layer.cornerCurve = .continuous
        iconCircle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconCircle)
        
        // SF Symbol inside — prominent, tinted green
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconCircle.addSubview(iconView)
        
        // === Site Name (centered, prominent) ===
        nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // === Plant Count (centered subtitle) ===
        countLabel.font = .systemFont(ofSize: 11, weight: .regular)
        countLabel.textColor = .secondaryLabel
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)
        
        // === Layout: Everything centered vertically ===
        NSLayoutConstraint.activate([
            // Icon circle — centered, large
            iconCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconCircle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconCircle.widthAnchor.constraint(equalToConstant: 44),
            iconCircle.heightAnchor.constraint(equalToConstant: 44),
            
            // SF Symbol inside circle
            iconView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            // Name — centered below icon
            nameLabel.topAnchor.constraint(equalTo: iconCircle.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            
            // Count — centered below name
            countLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }
    
    // MARK: - Configure
    func configure(name: String, icon: String, plantCount: Int, index: Int = 0) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        nameLabel.text = name
        countLabel.text = "\(plantCount) plant\(plantCount == 1 ? "" : "s")"
        
        // Safety
        siteNameLabel?.text = name
        plantCountLabel?.text = "\(plantCount) plant\(plantCount == 1 ? "" : "s")"
        iconButton?.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    // MARK: - Tap Feedback
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction]) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
}
