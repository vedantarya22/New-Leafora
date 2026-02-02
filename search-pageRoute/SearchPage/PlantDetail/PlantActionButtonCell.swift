//
//  PlantActionButtonCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 29/01/26.
//

import UIKit

class PlantActionButtonCell: UICollectionViewCell {

    @IBOutlet weak var plantActionButton: UIButton!
    
    // A closure to send the tap event back to the View Controller
        var onTap: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        plantActionButton.layer.cornerRadius = 16 // Adjust for roundness
                plantActionButton.clipsToBounds = true
    }
    
    
    @IBAction func plantActionButtonTapped(_ sender: UIButton) {
        onTap?()
    }
    
    enum ActionType {
            case addPlant
            case visualizeAR
        }
    
    func configure(type: ActionType){
        
        switch type {
                case .addPlant:
                    plantActionButton.setTitle("Add Plant", for: .normal)
                    // Solid Green Style
                    
                case .visualizeAR:
                    plantActionButton.setTitle("Visualize it in AR View", for: .normal)

                }
        
    }
    
    
    
  

}
