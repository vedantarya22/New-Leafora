import UIKit

class PlantStatusCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusIconView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nextWateringLabel: UILabel!
    @IBOutlet weak var healthProgressView: UIProgressView!
    @IBOutlet weak var healthPercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Container styling
        containerView.layer.cornerRadius = 16
        containerView.layer.cornerCurve = .continuous
        containerView.backgroundColor = .secondarySystemGroupedBackground
        
        // Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.06
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.layer.masksToBounds = false
        
        // Status icon
        statusIconView.layer.cornerRadius = 20
        statusIconView.layer.cornerCurve = .continuous
        
        // Labels
        statusLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nextWateringLabel.font = .systemFont(ofSize: 14, weight: .regular)
        nextWateringLabel.textColor = .secondaryLabel
        healthPercentageLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        
        // Progress view
        healthProgressView.layer.cornerRadius = 4
        healthProgressView.clipsToBounds = true
        healthProgressView.progressTintColor = .systemGreen
        healthProgressView.trackTintColor = UIColor.systemGreen.withAlphaComponent(0.15)
    }
    
    func configure(status: String, nextWatering: String, healthPercentage: Int) {
        statusLabel.text = status
        nextWateringLabel.text = "Next watering \(nextWatering)"
        healthPercentageLabel.text = "\(healthPercentage)%"
        
        // Set progress
        healthProgressView.setProgress(Float(healthPercentage) / 100.0, animated: false)
        
        // Status color
        let statusColor: UIColor
        if healthPercentage >= 80 {
            statusColor = .systemGreen
            statusLabel.textColor = .systemGreen
        } else if healthPercentage >= 50 {
            statusColor = .systemYellow
            statusLabel.textColor = .systemYellow
        } else {
            statusColor = .systemOrange
            statusLabel.textColor = .systemOrange
        }
        
        statusIconView.backgroundColor = statusColor.withAlphaComponent(0.15)
        healthProgressView.progressTintColor = statusColor
        healthProgressView.trackTintColor = statusColor.withAlphaComponent(0.15)
        healthPercentageLabel.textColor = statusColor
    }
}
