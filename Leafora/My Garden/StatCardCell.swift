import UIKit

class StatCardCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var statValueLabel: UILabel!
    @IBOutlet weak var statTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Container styling
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        containerView.backgroundColor = .secondarySystemGroupedBackground
        
        // Subtle shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.masksToBounds = false
        
        // Icon background
        iconBackgroundView.layer.cornerRadius = 10
        iconBackgroundView.layer.cornerCurve = .continuous
        
        // Labels
        statValueLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statValueLabel.textColor = .secondaryLabel
        
        statTitleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        statTitleLabel.textColor = .label
        statTitleLabel.numberOfLines = 2
        statTitleLabel.adjustsFontSizeToFitWidth = true
        statTitleLabel.minimumScaleFactor = 0.8
        
        iconImageView.contentMode = .scaleAspectFit
    }
    
    func configure(icon: String, title: String, value: String, color: UIColor) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        iconImageView.image = UIImage(systemName: icon, withConfiguration: config)
        iconImageView.tintColor = color
        
        iconBackgroundView.backgroundColor = color.withAlphaComponent(0.12)
        
        statTitleLabel.text = title
        statValueLabel.text = value

    }
}
