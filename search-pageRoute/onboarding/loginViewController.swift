//
//  loginViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

class loginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!
    
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Add any additional setup here (e.g., tap gestures for labels)
        setupGestures()
    }
    
    private func setupGestures() {
        // Example: Add tap gesture to SignUp Label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSignUpTap))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Navigate to Onboarding
        navigateToOnboarding()
    }
    
    @objc private func handleSignUpTap() {
        print("Sign Up Tapped")
    }
    
    // MARK: - Navigation
    private func navigateToOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Assuming the ID for the onboarding view controller (the one with the PageViewController or the initial onboarding VC)
        // Based on previous context, the initial onboarding screen is `onboardingViewController` with ID `onboardingVC`?
        // Let's check the implementation plan or previous knowledge. The user said "1st screen of the onboardingVC".
        // In `Main.storyboard`, `onboardingViewController` has ID `onboardingVC` (verified in previous turns).
        
        if let preQuestionsVC = storyboard.instantiateViewController(withIdentifier: "preQuestionsVC") as? preQuestionsViewController {
            if let nav = navigationController {
                nav.pushViewController(preQuestionsVC, animated: true)
//            } else {
//                onboardingVC.modalPresentationStyle = .fullScreen
//                present(onboardingVC, animated: true, completion: nil)
            }
        } else {
            print("Could not instantiate onboardingVC")
        }
    }
}
