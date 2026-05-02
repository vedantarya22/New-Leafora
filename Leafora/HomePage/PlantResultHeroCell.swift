import UIKit

class PlantResultHeroCell: UICollectionViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDesign()
    }
    
    private func setupDesign() {
        plantImageView.layer.cornerRadius = 20
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
    }
    
    func configure(with image: UIImage) {
        plantImageView.image = image
    }
}
