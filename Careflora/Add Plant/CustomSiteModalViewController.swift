//
//  CustomSiteModalViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class CustomSiteModalViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var customSiteTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    
    var onSiteEntered: ((String) -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    private func setupUI() {
        // Round only top corners
        containerView.layer.cornerRadius = 35
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        
        customSiteTextField.layer.borderWidth = 1
        customSiteTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        // Round check button
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        
        let text = customSiteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if !text.isEmpty {
            onSiteEntered?(text)
            dismiss(animated: true)
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
