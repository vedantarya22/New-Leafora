import UIKit

class CareGuideCell: UICollectionViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.cornerCurve = .continuous
        // Shadow Setup
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.08
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        return v
    }()
    
    private let iconBackground: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.cornerCurve = .continuous
        return v
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .label
        return lbl
    }()
    
    // NEW: Due Date Label (Top Right)
    private let dueLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textAlignment = .right
        return lbl
    }()
    
    // This label will hold either "Show More" OR the full steps
    private let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.numberOfLines = 0 // Crucial for expanding
        return lbl
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconBackground)
        iconBackground.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dueLabel) // Add new label
        containerView.addSubview(statusLabel)
        
        iconBackground.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dueLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Dynamic Constraints
        NSLayoutConstraint.activate([
            // Card Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Icon Square
            iconBackground.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconBackground.widthAnchor.constraint(equalToConstant: 40),
            iconBackground.heightAnchor.constraint(equalToConstant: 40),
            
            // Icon Image Center
            iconImageView.centerXAnchor.constraint(equalTo: iconBackground.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Title (Left)
            titleLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconBackground.trailingAnchor, constant: 16),
            
            // Due Label (Right)
            dueLabel.centerYAnchor.constraint(equalTo: iconBackground.centerYAnchor),
            dueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            dueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            
            // Status/Body Text (Below Icon)
            statusLabel.topAnchor.constraint(equalTo: iconBackground.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // CRITICAL: This pulls the bottom of the card down to match the text
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    func configure(icon: String, title: String, dueText: String, color: UIColor, body: String, isExpanded: Bool) {
        
        iconImageView.image = UIImage(systemName: icon)
        titleLabel.text = title
        dueLabel.text = dueText
        dueLabel.textColor = color // Match the theme color
        
        // Theme Coloring
        iconBackground.backgroundColor = color.withAlphaComponent(0.1)
        iconImageView.tintColor = color
        
        // Expansion Logic
        if isExpanded {
            // Show full steps
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            let attrString = NSAttributedString(
                string: body,
                attributes: [
                    .paragraphStyle: paragraphStyle,
                    .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            statusLabel.attributedText = attrString
            
            // Highlight border when open
            containerView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
            containerView.layer.borderWidth = 1.5
            
        } else {
            // Show collapsed state
            statusLabel.text = "Show Steps..."
            statusLabel.textColor = color
            statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            
            // Remove border
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
        }
    }
}
