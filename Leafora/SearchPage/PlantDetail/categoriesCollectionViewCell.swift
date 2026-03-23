import UIKit

class categoriesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    static let identifier = "categoriesCollectionViewCell"
    
    private let plantGreens: [UIColor] = [
        UIColor(red: 0.85, green: 0.93, blue: 0.88, alpha: 1.0), // soft mint
        UIColor(red: 0.78, green: 0.89, blue: 0.78, alpha: 1.0), // sage
        UIColor(red: 0.88, green: 0.94, blue: 0.85, alpha: 1.0), // pale lime
        UIColor(red: 0.73, green: 0.85, blue: 0.75, alpha: 1.0), // dusty fern
        UIColor(red: 0.82, green: 0.91, blue: 0.80, alpha: 1.0), // moss
        UIColor(red: 0.90, green: 0.95, blue: 0.90, alpha: 1.0), // ice green
        UIColor(red: 0.80, green: 0.88, blue: 0.82, alpha: 1.0), // eucalyptus
        UIColor(red: 0.86, green: 0.93, blue: 0.78, alpha: 1.0)  // sprout
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // leaf-like shape
        categoryView.layer.cornerRadius = 35
        
        // round top-left and bottom-right corners
        categoryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
        categoryView.clipsToBounds = true
        
        // image style
        categoryImageView.contentMode = .scaleAspectFit
        
        // dynamic image size; avoid fixed xib constraints
        categoryImageView.translatesAutoresizingMaskIntoConstraints = false
        // deactivate xib width/height constraints
        categoryImageView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        NSLayoutConstraint.activate([
            categoryImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.30),
            categoryImageView.heightAnchor.constraint(equalTo: categoryImageView.widthAnchor, multiplier: 1.0)
        ])
        
        // text fit safety
        categoryLabel.adjustsFontSizeToFitWidth = true
        categoryLabel.minimumScaleFactor = 0.6
        categoryLabel.numberOfLines = 2
    }

    func configure(with category: Category) {
        categoryLabel.text = category.title
        categoryImageView.image = UIImage(named: category.assetName)
        
        // stable green tone per category
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
