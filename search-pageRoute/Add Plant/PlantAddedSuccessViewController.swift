//
//  PlantAddedSuccessViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class PlantAddedSuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupBeautifulUI()
    }
    
    private func setupBeautifulUI() {
        // Clear storyboard subviews so they don't peek through or interfere
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Beautiful Botanical Dark Green Background
        view.backgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        
        // Setup Icon Container
        let iconContainer = UIView()
        iconContainer.backgroundColor = .white.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 50
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon Image
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold)
        let iconImageView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill", withConfiguration: iconConfig))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(iconImageView)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Plant Added!"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your new plant has been successfully planted in your digital garden."
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // "Go to Site" (My Garden) Button
        let siteButton = UIButton(type: .system)
        siteButton.setTitle("Go to Site", for: .normal)
        siteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        siteButton.setTitleColor(UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0), for: .normal)
        siteButton.backgroundColor = .white
        siteButton.layer.cornerRadius = 14
        
        // Add shadow for depth
        siteButton.layer.shadowColor = UIColor.black.cgColor
        siteButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        siteButton.layer.shadowOpacity = 0.1
        siteButton.layer.shadowRadius = 8
        
        siteButton.translatesAutoresizingMaskIntoConstraints = false
        siteButton.addTarget(self, action: #selector(gardenButtonAction), for: .touchUpInside)
        
        // "Continue Exploring" Button
        let exploreButton = UIButton(type: .system)
        exploreButton.setTitle("Continue Exploring", for: .normal)
        exploreButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        exploreButton.setTitleColor(.white, for: .normal)
        exploreButton.backgroundColor = .clear
        exploreButton.layer.cornerRadius = 14
        exploreButton.layer.borderWidth = 2
        exploreButton.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        exploreButton.translatesAutoresizingMaskIntoConstraints = false
        exploreButton.addTarget(self, action: #selector(exploreButtonAction), for: .touchUpInside)
        
        // View Hierarchy
        view.addSubview(iconContainer)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(siteButton)
        view.addSubview(exploreButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Icon
            iconContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            iconContainer.widthAnchor.constraint(equalToConstant: 100),
            iconContainer.heightAnchor.constraint(equalToConstant: 100),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Buttons
            siteButton.bottomAnchor.constraint(equalTo: exploreButton.topAnchor, constant: -16),
            siteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            siteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            siteButton.heightAnchor.constraint(equalToConstant: 56),
            
            exploreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            exploreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            exploreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            exploreButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add a subtle entrance animation
        iconContainer.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        iconContainer.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        titleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        subtitleLabel.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            iconContainer.transform = .identity
            iconContainer.alpha = 1
            titleLabel.transform = .identity
            titleLabel.alpha = 1
            subtitleLabel.transform = .identity
            subtitleLabel.alpha = 1
        }, completion: nil)
    }
    
    // MARK: - Actions

    @objc private func exploreButtonAction() {
        // Equivalent to old exploreButtonTapped
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func gardenButtonAction() {
        // Equivalent to old gardenButtonTapped
        tabBarController?.selectedIndex = 1
        navigationController?.popToRootViewController(animated: true)
    }

    // Keep the IBActions so Storyboard doesn't crash if it tries to link them
    @IBAction func exploreButtonTapped(_ sender: UIButton) { exploreButtonAction() }
    @IBAction func gardenButtonTapped(_ sender: UIButton) { gardenButtonAction() }
}
