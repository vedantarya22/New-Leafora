import UIKit

class WeatherTipCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // Use the size provided by the flow layout delegate
        return layoutAttributes
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0)
        
        // Soft Shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        containerView.layer.masksToBounds = false
        
    }

    // MARK: - Integration Functions

    // 1. Fixes: "has no member 'configure'"
    func configure(with weather: PlantWeatherInfo) {
        titleLabel.text = "Great day for your plants!"
        subtitleLabel.text = "\(weather.condition), \(weather.temperature)°C — \(weather.plantAdvice)"
        weatherIcon.image = UIImage(systemName: weather.weatherSFSymbol) // Use SF Symbol
        weatherIcon.tintColor = .systemYellow
    }

    // 2. Fixes: "has no member 'showLoading'"
    func showLoading() {
        titleLabel.text = "Updating weather..."
        subtitleLabel.text = "Checking conditions for your garden..."
        weatherIcon.image = UIImage(systemName: "cloud.sun.fill")
        weatherIcon.tintColor = .systemGray
    }

    // 3. Fixes: "has no member 'showError'"
    func showError() {
        titleLabel.text = "Weather Unavailable"
        subtitleLabel.text = "Check your connection to get plant tips."
        weatherIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        weatherIcon.tintColor = .systemOrange
    }
}
