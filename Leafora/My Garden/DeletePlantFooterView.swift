//
//  DeletePlantFooterView.swift
//  search-pageRoute
//
//  Created by SDC-USER on 02/03/26.
//

import UIKit

class DeletePlantFooterView: UICollectionReusableView {
    @IBOutlet weak var deleteButton: UIButton!
    
    var onDeleteTapped: (() -> Void)?

    @IBAction func didTapDelete(_ sender: Any) {
        onDeleteTapped?()
    }
}
