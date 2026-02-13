//
//  CareStepCard.swift
//  search-pageRoute
//
//  Created by SDC-USER on 06/02/26.
//

import UIKit


class CareStepCard: UIView {
    private let stack = UIStackView()
    private let header = UIStackView()
    private let bodyLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    init(icon: String, title: String, body: String, isExpanded: Bool) {
        super.init(frame: .zero)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        
        // Setup Header (Icon + Title + Chevron)
        header.axis = .horizontal
        header.spacing = 12
        header.alignment = .center
        
        let iconLbl = UILabel()
        iconLbl.text = icon
        iconLbl.font = .systemFont(ofSize: 24)
        
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 18, weight: .semibold)
        
        chevron.tintColor = .systemGray2
        chevron.contentMode = .scaleAspectFit
        chevron.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi/2) : .identity

        header.addArrangedSubview(iconLbl)
        header.addArrangedSubview(titleLbl)
        header.addArrangedSubview(UIView()) // Spacer
        header.addArrangedSubview(chevron)
        
        // Setup Body
        bodyLabel.text = body
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 15)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.isHidden = !isExpanded
        
        // Main Stack
        stack.axis = .vertical
        stack.spacing = 12
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(header)
        stack.addArrangedSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
