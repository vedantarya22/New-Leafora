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
        // setup done in storyboard and gradient here
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    @IBAction func beginButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
        if let questionsVC = storyboard.instantiateViewController(withIdentifier: "onboardingQuestionViewController") as? onboardingQuestionViewController {
            // push if embedded in nav, else present full screen
            if let nav = navigationController {
                nav.pushViewController(questionsVC, animated: true)
            } else {
                questionsVC.modalPresentationStyle = .fullScreen
                present(questionsVC, animated: true, completion: nil)
            }
        }
    }
}
