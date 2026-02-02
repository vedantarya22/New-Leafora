//
//  PeopleTableViewCell.swift
//  garden_app
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {

    //xib connections
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        avatarImageView.layer.cornerRadius = 25 // Half of height (50)
        avatarImageView.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //chnage view for the selected state
    }
}
