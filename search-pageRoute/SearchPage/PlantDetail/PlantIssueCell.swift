//
//  PlantIssueCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantIssueCell: UICollectionViewCell {
    
    

    @IBOutlet weak var issueLabel: UILabel!
    
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func applyCorners(isFirst: Bool, isLast: Bool) {
        
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        layer.cornerRadius = 16
        layer.masksToBounds = true

        if isFirst && isLast {
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        else if isFirst {
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
        }
        else if isLast {
            layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        else {
            layer.cornerRadius = 0
        }
    }
    
    func configure(issue: String,isLast:Bool) {
            issueLabel.text = issue
        separatorView.isHidden = isLast
        
        }
    
    

}
