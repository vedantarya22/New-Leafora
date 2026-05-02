import UIKit

class ScanPlantCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    
    private var dashedBorder: CAShapeLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0)
        iconBackgroundView.layer.cornerRadius = 12
        iconBackgroundView.backgroundColor = UIColor(red: 0.35, green: 0.58, blue: 0.45, alpha: 0.15)
    }
    
}
