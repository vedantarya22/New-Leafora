//
//  UIViewController+Alerts.swift .swift
//  PlantApp
//
//  Created by SDC-USER on 10/12/25.
//

import Foundation
import UIKit

extension UIViewController {
    func showSelectionAlert(
        title: String = "Please select an option",
        message: String = "You must choose one answer before continuing."
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    func showSuccessFlash(message: String, completion: @escaping () -> Void) {
        let flashView = UIView()
        flashView.backgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 0.95)
        flashView.layer.cornerRadius = 22
        flashView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "✓ \(message)"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        flashView.addSubview(label)
        self.view.addSubview(flashView)
        
        NSLayoutConstraint.activate([
            flashView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            flashView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            flashView.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: flashView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: flashView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: flashView.centerYAnchor)
        ])
        
        flashView.alpha = 0
        flashView.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(withDuration: 0.4, animations: {
            flashView.alpha = 1
            flashView.transform = .identity
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                UIView.animate(withDuration: 0.3, animations: {
                    flashView.alpha = 0
                    flashView.transform = CGAffineTransform(translationX: 0, y: -20)
                }) { _ in
                    flashView.removeFromSuperview()
                    completion()
                }
            }
        }
    }
}

