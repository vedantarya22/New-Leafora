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
    private let pageControl = UIPageControl()
    
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
        setupUI()
        // PageControl and Gestures are called within setupUI or after
        setupGestures()
        setupPageControl() // Ensure this is styled correctly
        updateUI(animated: false)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Disable autoresizing masks to use programmatic constraints
        [logo, functionalityPic, functionalityTitle, functionalityDesc, nextButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Ensure multiline label
        functionalityTitle.numberOfLines = 0
        functionalityTitle.textAlignment = .center
        functionalityTitle.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        functionalityDesc.numberOfLines = 0
        functionalityDesc.textAlignment = .center
        functionalityDesc.textColor = .secondaryLabel
        
        // Define standard padding
        let padding: CGFloat = 24
        
        // Add Constraints
        NSLayoutConstraint.activate([
            // Logo (Top) - Optional, assuming logo exists
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.heightAnchor.constraint(equalToConstant: 40), // Adjust as needed
            logo.widthAnchor.constraint(equalToConstant: 120), // Adjust as needed
            
            // Image (Middle-Top)
            functionalityPic.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 10),
            functionalityPic.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            functionalityPic.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            functionalityPic.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            functionalityPic.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4), // Take up 40% of screen height
            //functionalityPic.contentMode = .scaleAspectFit,
            
            // Title (Below Image)
            functionalityTitle.topAnchor.constraint(equalTo: functionalityPic.bottomAnchor, constant: 30),
            functionalityTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            functionalityTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Description (Below Title)
            functionalityDesc.topAnchor.constraint(equalTo: functionalityTitle.bottomAnchor, constant: 16),
            functionalityDesc.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            functionalityDesc.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Next Button (Bottom)
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            nextButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        // Style Next Button
        nextButton.backgroundColor = .systemGreen
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 25
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemGreen
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            pageControl.heightAnchor.constraint(equalToConstant: 30) // Ensure it has some height
        ])
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
            // For now, we just print, as per instruction "dont connect it with main.storyboard or anything just yet"
            print("Onboarding Finished!")
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
