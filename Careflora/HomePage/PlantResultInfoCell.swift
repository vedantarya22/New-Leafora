import UIKit

class PlantResultInfoCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // main stack from xib
    private var mainStack: UIStackView? {
        return containerView.subviews.first(where: { $0 is UIStackView }) as? UIStackView
    }
    
    // dynamic stack added at runtime
    private var customStack: UIStackView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCard()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customStack?.removeFromSuperview()
        customStack = nil
        descriptionLabel.isHidden = false
        descriptionLabel.text = nil
        iconImageView.image = nil
    }
    
    private func setupCard() {
        containerView.backgroundColor = UIColor.secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 20
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.04
        containerView.layer.masksToBounds = false
        self.clipsToBounds = false
        
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        iconImageView?.contentMode = .scaleAspectFit
    }
    
    // MARK: - About (Name + Confidence + Common Names)
    func configureAbout(name: String, confidence: Int, commonNames: String?) {
        titleLabel.text = name
        iconImageView.image = UIImage(systemName: "leaf.fill")
        iconImageView.tintColor = UIColor(red: 0.28, green: 0.65, blue: 0.40, alpha: 1.0)
        
        descriptionLabel.isHidden = true
        
        let confidenceLabel = UILabel()
        confidenceLabel.text = "\(confidence)% Match"
        confidenceLabel.font = .systemFont(ofSize: 16, weight: .bold)
        confidenceLabel.textColor = UIColor(red: 0.28, green: 0.65, blue: 0.40, alpha: 1.0)
        
        var views: [UIView] = [confidenceLabel]
        
        if let names = commonNames, !names.isEmpty {
            let namesLabel = UILabel()
            namesLabel.text = "Also known as: \(names)"
            namesLabel.font = .systemFont(ofSize: 15, weight: .regular)
            namesLabel.textColor = .secondaryLabel
            namesLabel.numberOfLines = 0
            views.append(namesLabel)
        }
        
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        
        mainStack?.addArrangedSubview(stack)
        customStack = stack
    }
    
    // MARK: - Description
    func configureDescription(text: String) {
        titleLabel.text = "About This Plant"
        iconImageView.image = UIImage(systemName: "info.circle.fill")
        iconImageView.tintColor = .systemBlue
        
        descriptionLabel.text = text
        descriptionLabel.isHidden = false
    }
    
    // MARK: - Taxonomy
    func configureTaxonomy(rows: [(label: String, value: String)]) {
        titleLabel.text = "Classification"
        iconImageView.image = UIImage(systemName: "list.bullet")
        iconImageView.tintColor = .systemPurple
        
        descriptionLabel.isHidden = true
        
        var rowViews: [UIView] = []
        for (index, row) in rows.enumerated() {
            let rowView = makeDetailRow(label: row.label, value: row.value)
            rowViews.append(rowView)
            
            if index < rows.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                
                let sepContainer = UIView()
                sepContainer.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: sepContainer.leadingAnchor, constant: 44),
                    separator.trailingAnchor.constraint(equalTo: sepContainer.trailingAnchor),
                    separator.topAnchor.constraint(equalTo: sepContainer.topAnchor),
                    separator.bottomAnchor.constraint(equalTo: sepContainer.bottomAnchor)
                ])
                rowViews.append(sepContainer)
            }
        }
        
        let stack = UIStackView(arrangedSubviews: rowViews)
        stack.axis = .vertical
        stack.spacing = 0
        
        mainStack?.addArrangedSubview(stack)
        customStack = stack
    }
    
    // MARK: - Other Matches
    func configureOtherMatches(suggestions: [PlantSuggestion]) {
        titleLabel.text = "Other Possible Matches"
        iconImageView.image = UIImage(systemName: "square.stack.fill")
        iconImageView.tintColor = .systemOrange
        
        descriptionLabel.isHidden = true
        
        var rowViews: [UIView] = []
        for suggestion in suggestions {
            let row = makeMatchRow(suggestion: suggestion)
            rowViews.append(row)
        }
        
        let stack = UIStackView(arrangedSubviews: rowViews)
        stack.axis = .vertical
        stack.spacing = 12
        
        mainStack?.addArrangedSubview(stack)
        customStack = stack
    }
    
    // MARK: - Component Builders
    
    private func makeDetailRow(label: String, value: String) -> UIView {
        let row = UIView()
        
        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(image: UIImage(systemName: "circle.fill"))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconBg.addSubview(iconView)
        
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 15, weight: .regular)
        valueLabel.textColor = .secondaryLabel
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        row.addSubview(iconBg)
        row.addSubview(titleLabel)
        row.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52),
            
            iconBg.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 130),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            valueLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12)
        ])
        
        return row
    }
    
    private func makeMatchRow(suggestion: PlantSuggestion) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.systemGray6
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = suggestion.plantName
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let probabilityLabel = UILabel()
        let percentage = Int(suggestion.probability * 100)
        probabilityLabel.text = "\(percentage)%"
        probabilityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        probabilityLabel.textColor = UIColor(red: 0.28, green: 0.65, blue: 0.40, alpha: 1.0)
        probabilityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(nameLabel)
        container.addSubview(probabilityLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: probabilityLabel.leadingAnchor, constant: -12),
            
            probabilityLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            probabilityLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        return container
    }
}
