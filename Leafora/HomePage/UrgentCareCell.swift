//
//  UrgentCareCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 06/02/26.
//

import UIKit
import SwiftUI

class UrgentCareCell: UICollectionViewCell {
    
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor(.white)
        contentView.layer.cornerRadius = 18
        
        // Optional: Subtle Border
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 0.70, green: 0.85, blue: 0.75, alpha: 1.0).cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chevronImageView.isHidden = false
    }
    
    
    
    func configure(with insight: TaskOverviewInsight) {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        iconImageView.image = UIImage(systemName: insight.icon, withConfiguration: config)
        
        titleLabel.text = insight.title
        subtitleLabel.text = insight.message
        
        // Apply colors based on level
        switch insight.level {
        case .critical:
            // Red theme for Urgent
            //               contentView.backgroundColor = UIColor(red: 1.00, green: 0.93, blue: 0.93, alpha: 1.0)
            contentView.layer.borderColor = UIColor(red: 1.00, green: 0.70, blue: 0.70, alpha: 1.0).cgColor
            iconImageView.tintColor = UIColor(red: 1.00, green: 0.07, blue: 0.33, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 1.00, green: 0.07, blue: 0.33, alpha: 1.0)
            
        case .warning:
            // Yellow/Orange theme for Missed
            //               contentView.backgroundColor = UIColor(red: 1.00, green: 0.97, blue: 0.89, alpha: 1.0)
            contentView.layer.borderColor = UIColor(red: 1.00, green: 0.85, blue: 0.60, alpha: 1.0).cgColor
            iconImageView.tintColor = UIColor(red: 1.00, green: 0.62, blue: 0.04, alpha: 1.0)
            titleLabel.textColor = UIColor(red: 1.00, green: 0.62, blue: 0.04, alpha: 1.0)
            
        case .good:
            // Green theme for All Clear / Healthy
            //               contentView.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.92, alpha: 1.0)
            contentView.layer.borderColor = UIColor(red: 0.70, green: 0.85, blue: 0.75, alpha: 1.0).cgColor
            
        }
        
        subtitleLabel.textColor = .secondaryLabel
    }
    
    func setChevronHidden(_ hidden: Bool) {
        chevronImageView.isHidden = hidden
    }
    
}
