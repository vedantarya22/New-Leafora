import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var radioImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .white
        backgroundColor = .clear
    }

    // supports single/multi select icon styles
    func configure(option: String, isSelected: Bool, isMultiSelect: Bool) {
        optionLabel.text = option
        
        if isSelected {
            radioImageView.image = UIImage(systemName: "checkmark.circle.fill")
            radioImageView.tintColor = .brandGreen
        } else {
            radioImageView.image = UIImage(systemName: "circle")
            radioImageView.tintColor = .brandGreen
        }
    }

}
