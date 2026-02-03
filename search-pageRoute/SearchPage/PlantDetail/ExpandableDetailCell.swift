//
//  ExpandableDetailCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit

class ExpandableDetailCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var chevronIcon: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var isExpanded: Bool = false
    var onToggle: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .systemGray6 // Subtle difference from the white card
        detailLabel.numberOfLines = 2 // Start collapsed
    }
    
    func configure(title: String, detailText: String) {
        titleLabel.text = title
        detailLabel.text = detailText
    }
    
    @IBAction func toggleExpand(_ sender: UIButton) {
        isExpanded.toggle()
        detailLabel.numberOfLines = isExpanded ? 0 : 2
        chevronIcon.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
        onToggle?()
    }
}
