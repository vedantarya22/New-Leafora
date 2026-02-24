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
        // Redraw dashed border if the frame changes
//        updateDashedBorder()
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0)
        iconBackgroundView.layer.cornerRadius = 12
        iconBackgroundView.backgroundColor = UIColor.systemMint.withAlphaComponent(0.2)
    }
    
//    private func updateDashedBorder() {
//        dashedBorder?.removeFromSuperlayer()
//        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor.systemMint.withAlphaComponent(0.4).cgColor
//        shapeLayer.lineDashPattern = [6, 4]
//        shapeLayer.frame = containerView.bounds
//        shapeLayer.fillColor = nil
//        shapeLayer.path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16).cgPath
//        shapeLayer.frame = containerView.bounds
//        
//        containerView.layer.addSublayer(shapeLayer)
//        dashedBorder = shapeLayer
//    }
}
