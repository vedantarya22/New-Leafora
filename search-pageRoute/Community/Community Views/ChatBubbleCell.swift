//
//  ChatBubbleCell.swift
//  garden_app
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class ChatBubbleCell: UITableViewCell {

    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageLabel.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
