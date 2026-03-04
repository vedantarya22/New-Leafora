//
//  MissingCareCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/03/26.
//


//
//  MissingCareCell.swift
//  PlantApp
//

import UIKit

class MissingCareCell: UICollectionViewCell {

    var onAnswerTapped: (() -> Void)?

    // MARK: - UI
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.80, alpha: 1.0) // warm yellow
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.text = "🌱"
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.text = "Answer some questions so we can take care of your plant"
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0)
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chevronImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor(red: 0.4, green: 0.3, blue: 0.1, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(chevronImage)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 36),

            chevronImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 12),

            messageLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -8),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onAnswerTapped?()
    }
}