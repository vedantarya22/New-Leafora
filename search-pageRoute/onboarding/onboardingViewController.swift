//
//  onboardingViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit

class onboardingViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var functionalityPic: UIImageView!
    @IBOutlet weak var functionalityTitle: UILabel!
    @IBOutlet weak var functionalityDesc: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Properties
    private var currentPage = 0
    @IBOutlet weak var pageControl: UIPageControl! // Added IBOutlet for PageControl
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    // Data Model
    struct OnboardingSlide {
        let title: String
        let description: String
        let imageName: String
    }
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Your Plants, Perfectly Organized",
            description: "Effortlessly track, manage, and care for all your plants in one calm, intuitive space.",
            imageName: "Screen1"
        ),
        OnboardingSlide(
            title: "Care, Personalized for Every Plant",
            description: "Smart insights adapt to each plant’s needs, helping them grow better with less effort.",
            imageName: "Screen2"
        ),
        OnboardingSlide(
            title: "Grow Together with the Community",
            description: "Discover plants, tips, and ideas shared by people growing alongside you.",
            imageName: "Screen3"
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageControl() 
        setupGestures()
        updateUI(animated: false)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    
    // MARK: - Setup
    private func setupPageControl() {
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        // Styling moved to Storyboard
    }

    
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    // MARK: - Actions
    @objc private func nextButtonTapped() {
        if currentPage < slides.count - 1 {
            currentPage += 1
            updateUI(animated: true)
        } else {
            // Already on last screen, user finished onboarding
            print("Onboarding Finished! Presenting Questions...")
            
            let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
            // Navigate to Pre-Questions Screen
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as? loginViewController {
                 if let nav = navigationController {
                     nav.pushViewController(loginVC, animated: true)
//                 } else {
//                     navigationController?.pushViewController(loginVC, animated: true)
                 }
            } else {
                print("Could not instantiate preQuestionsVC. Check Storyboard ID.")
            }
        }
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if currentPage < slides.count - 1 {
                currentPage += 1
                updateUI(animated: true, transitionSubtype: .fromRight)
            }
        } else if gesture.direction == .right {
            if currentPage > 0 {
                currentPage -= 1
                updateUI(animated: true, transitionSubtype: .fromLeft)
            }
        }
    }
    
    // MARK: - Updates
    private func updateUI(animated: Bool, transitionSubtype: CATransitionSubtype? = nil) {
        let slide = slides[currentPage]
        
        // Update Page Control
        pageControl.currentPage = currentPage
        
        // Update Content
        if animated {
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = .push
            
            // Default to .fromRight if not specified (e.g. Next button)
            transition.subtype = transitionSubtype ?? .fromRight
            
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Apply transition to specific container views if possible, or individual views
            // Applying to self.view works but animates the whole screen including background
            // Let's apply cross dissolve to text/images for a smoother feel without jarring whole-screen movement if background is static
            
            // Actually, user asked for "smooth flow". A push transition on the content views looks like pages turning.
            functionalityPic.layer.add(transition, forKey: nil)
            functionalityTitle.layer.add(transition, forKey: nil)
            functionalityDesc.layer.add(transition, forKey: nil)
        }
        
        functionalityTitle.text = slide.title
        functionalityDesc.text = slide.description
        functionalityPic.image = UIImage(named: slide.imageName)
        
        // Update Button Text
        let buttonTitle = (currentPage == slides.count - 1) ? "Get Started" : "Next"
        nextButton.setTitle(buttonTitle, for: .normal)
    }
}
