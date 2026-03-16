//
//  ProfileGridCell.swift
//  garden_app
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class ProfileGridCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
        
        override func awakeFromNib() {
            super.awakeFromNib()
            imageView.contentMode  = .scaleAspectFill
            imageView.clipsToBounds = true
            
            // Pin imageView to fill the entire cell
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
        }
    
}
