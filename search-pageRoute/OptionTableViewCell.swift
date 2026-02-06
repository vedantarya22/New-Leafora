//
//  OptionTableViewCell.swift
//  search-pageRoute
//
//  Created by SDC-USER on 06/02/26.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    let containerView = UIView()
    let optionLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Setup Container View
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        containerView.backgroundColor = .white
        
        // Shadow (from previous code intent)
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        
        // Setup Label
        containerView.addSubview(optionLabel)
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        optionLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        optionLabel.textColor = .label
        optionLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4), // Margins
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            optionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            optionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            optionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            optionLabel.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 12),
            optionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(option: QuestionOption, isSelected: Bool) {
        optionLabel.text = option.label
        
        if isSelected {
            containerView.layer.borderColor = UIColor.systemGreen.cgColor
            containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            optionLabel.textColor = UIColor.systemGreen
        } else {
            containerView.layer.borderColor = UIColor.systemGray5.cgColor
            containerView.backgroundColor = .white
            optionLabel.textColor = .label
        }
    }
    
    // Legacy support for string (if needed during transition, though we should move to `QuestionOption`)
    func configure(option: String, isSelected: Bool) {
         optionLabel.text = option
         
         if isSelected {
             containerView.layer.borderColor = UIColor.systemGreen.cgColor
             containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
             optionLabel.textColor = UIColor.systemGreen
         } else {
             containerView.layer.borderColor = UIColor.systemGray5.cgColor
             containerView.backgroundColor = .white
             optionLabel.textColor = .label
         }
     }
}
