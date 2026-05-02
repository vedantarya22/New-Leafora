//
//  PlantAddedSuccessViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class PlantAddedSuccessViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupBotanicalBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
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
