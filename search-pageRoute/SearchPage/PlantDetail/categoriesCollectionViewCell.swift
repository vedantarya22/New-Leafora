import UIKit

class categoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    static let identifier = "categoriesCollectionViewCell"
    
    private let plantGreens: [UIColor] = [
        UIColor(red: 0.85, green: 0.93, blue: 0.88, alpha: 1.0), // Soft Mint
        UIColor(red: 0.78, green: 0.89, blue: 0.78, alpha: 1.0), // Sage
        UIColor(red: 0.88, green: 0.94, blue: 0.85, alpha: 1.0), // Pale Lime
        UIColor(red: 0.73, green: 0.85, blue: 0.75, alpha: 1.0), // Dusty Fern
        UIColor(red: 0.82, green: 0.91, blue: 0.80, alpha: 1.0), // Moss
        UIColor(red: 0.90, green: 0.95, blue: 0.90, alpha: 1.0), // Ice Green
        UIColor(red: 0.80, green: 0.88, blue: 0.82, alpha: 1.0), // Eucalyptus
        UIColor(red: 0.86, green: 0.93, blue: 0.78, alpha: 1.0)  // Sprout
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 1. THE NEW LEAF SHAPE
        categoryView.layer.cornerRadius = 35
        
        // CHANGE: Round Top-Left and Bottom-Right.
        // This leaves Top-Right and Bottom-Left SHARP (Pointy).
        categoryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        categoryView.clipsToBounds = true
        
        // 2. Image Styling
        categoryImageView.contentMode = .scaleAspectFit
        
        // 3. Dynamic image size — removes dependency on the XIB's fixed 65pt constraints.
        //    Width = 30% of the cell's content view width; height = width (1:1 square).
        //    This makes the image scale correctly on iPhone 17 and 17 Pro Max alike.
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        // Deactivate any existing width/height constraints set in the XIB
        categoryImageView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        NSLayoutConstraint.activate([
            categoryImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.30),
            categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor, multiplier: 1.0)
        ])
        
        // 4. Text Safety
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.minimumScaleFactor = 0.6
        categoryLabel.numberOfLines = 2
    }

    func configure(with category: Category) {
        categoryLabel.text = category.title
        categoryImageView.image = UIImage(named: category.assetName)
        
        // Pick a consistent green for this category
        let colorIndex = abs(category.title.hashValue) % plantGreens.count
        let selectedGreen = plantGreens[colorIndex]
        
        applyPlantTheme(bgColor: selectedGreen)
    }

    private func applyPlantTheme(bgColor: UIColor) {
        categoryView.backgroundColor = bgColor
        categoryLabel.textColor = UIColor(red: 0.1, green: 0.25, blue: 0.1, alpha: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryView.backgroundColor = .systemGray6
        categoryLabel.textColor = .black
    }
}
