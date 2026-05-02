import UIKit

class HomeSectionHeaderView: UICollectionReusableView {
    
   
    @IBOutlet weak var titleLabel: UILabel!
  
    @IBOutlet weak var chevronButton: UIButton!
    
    // A closure (function) to run when clicked
    var didTapSeeAll: (() -> Void)?
    
    static let reuseIdentifier = "HomeSectionHeaderView"

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = UIColor(red: 0.1, green: 0.18, blue: 0.1, alpha: 1.0)
        // Make the button invisible by default (we only show it for Memories)
        chevronButton.isHidden = true
        chevronButton.tintColor = .darkGray
    }
    
    @IBAction func chevronTapped(_ sender: UIButton) {
        // Trigger the action
        didTapSeeAll?()
    }
}
