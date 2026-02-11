//
//  preQuestionsViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

class preQuestionsViewController: UIViewController {
    
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    @IBAction func beginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let questionsVC = storyboard.instantiateViewController(withIdentifier: "onboardingQuestionViewController") as? onboardingQuestionViewController {
            // Check if we are in a navigation controller
            if let nav = navigationController {
                nav.pushViewController(questionsVC, animated: true)
            } else {
                questionsVC.modalPresentationStyle = .fullScreen
                present(questionsVC, animated: true, completion: nil)
            }
        }
    }
}
