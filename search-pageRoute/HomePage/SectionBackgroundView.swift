import UIKit

class SectionBackgroundView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Load the Nib from the bundle
        let nib = UINib(nibName: "SectionBackgroundView", bundle: nil)
        
        // Ensure we are grabbing the view, but since 'File's Owner' is now the class,
        // we pass 'self' as the owner.
        guard let contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        // Add the XIB view to this ReusableView
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        // Apply the Figma styling to the ReusableView container
        self.backgroundColor = .white
        self.layer.cornerRadius = 24
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.05
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 12
        self.layer.masksToBounds = false
    }
}
