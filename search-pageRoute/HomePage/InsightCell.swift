//
//  InsightCell.swift
//  homescreen1
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class InsightCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor(named: "InsightGreen") // Add to assets
        self.contentView.layer.cornerRadius = 12
    }
}
