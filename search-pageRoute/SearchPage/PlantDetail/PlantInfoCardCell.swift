import UIKit

class PlantInfoCardCell: UICollectionViewCell {
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
        // clear dynamic stack before reuse
        customStack?.removeFromSuperview()
        customStack = nil
        
        descriptionLabel.isHidden = false
        descriptionLabel.text = nil
        iconImageView.image = nil
    }

    private func setupCard() {
        // card background style
        containerView.backgroundColor = UIColor.secondarySystemGroupedBackground
        containerView.layer.cornerRadius = 20
        
        // subtle shadow
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

    // MARK: - Basic Configure
    func configure(title: String, text: String, iconName: String, iconColor: UIColor) {
        titleLabel.text = title
        descriptionLabel.text = text
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
    }

    // MARK: - About Section
    func configureAbout(description: String, light: String, difficulty: String, petStatus: String, isPetFriendly: Bool) {
        titleLabel.text = "About"
        iconImageView.image = UIImage(systemName: "info.circle.fill")
        iconImageView.tintColor = .systemBlue

        descriptionLabel.text = description
        descriptionLabel.isHidden = false

        let lightChip = makeInfoChip(icon: "sun.max.fill", text: light, tint: .systemYellow)
        let difficultyChip = makeInfoChip(icon: "chart.bar.fill", text: difficulty, tint: .systemGreen)
        let petChip = makeInfoChip(
            icon: isPetFriendly ? "pawprint.fill" : "exclamationmark.triangle.fill",
            text: petStatus,
            tint: isPetFriendly ? .systemGreen : .systemRed
        )

        let stack = UIStackView(arrangedSubviews: [lightChip, difficultyChip, petChip])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        
        // spacing above chips
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true

        mainStack?.addArrangedSubview(stack)
        customStack = stack
    }

    // MARK: - Detail Rows
    func configureDetailRows(title: String, iconName: String, iconColor: UIColor, rows: [(icon: String, label: String, value: String)]) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor

        descriptionLabel.isHidden = true

        var rowViews: [UIView] = []
        for (index, row) in rows.enumerated() {
            let rowView = makeDetailRow(icon: row.icon, label: row.label, value: row.value)
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

    // MARK: - Issue List Rows
    func configureIssueList(title: String, issues: [String]) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        iconImageView.tintColor = .systemOrange

        descriptionLabel.isHidden = true

        var rowViews: [UIView] = []
        for (index, issue) in issues.enumerated() {
            let rowView = makeIssueRow(text: issue)
            rowViews.append(rowView)

            if index < issues.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.separator.withAlphaComponent(0.3)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                
                let sepContainer = UIView()
                sepContainer.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: sepContainer.leadingAnchor, constant: 28),
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

    // MARK: - Component Builders

    private func makeInfoChip(icon: String, text: String, tint: UIColor) -> UIView {
        let container = UIView()
        container.backgroundColor = tint.withAlphaComponent(0.12)
        container.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = tint
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = tint
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4)
        ])

        return container
    }

    private func makeDetailRow(icon: String, label: String, value: String) -> UIView {
        let row = UIView()
        
        let iconBg = UIView()
        iconBg.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 8
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: icon))
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
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 52), // extra padding

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

    private func makeIssueRow(text: String) -> UIView {
        let row = UIView()

        let iconView = UIImageView(image: UIImage(systemName: "circle.fill"))
        iconView.tintColor = .systemOrange
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(iconView)
        row.addSubview(label)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            iconView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 8),
            iconView.heightAnchor.constraint(equalToConstant: 8),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            label.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12)
        ])

        return row
    }
}
