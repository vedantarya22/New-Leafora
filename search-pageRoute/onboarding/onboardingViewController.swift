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
    @IBOutlet weak var pageControl: UIPageControl!
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "Your Plants, Perfectly Organized",
            description: "Effortlessly track, manage, and care for all your plants in one calm, intuitive space.",
            imageName: "Screen1"
        ),
        OnboardingSlide(
            title: "Care, Personalized for Every Plant",
            description: "Smart insights adapt to each plant's needs, helping them grow better with less effort.",
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addFloatingAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func addFloatingAnimation() {
        let hover = CABasicAnimation(keyPath: "position.y")
        hover.isAdditive = true
        hover.fromValue = -15
        hover.toValue = 15
        hover.autoreverses = true
        hover.duration = 2.5
        hover.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        hover.repeatCount = .infinity
        
        functionalityPic.layer.add(hover, forKey: "hoverAnimation")
    }
    
    // MARK: - Setup
    private func setupPageControl() {
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
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
    @IBAction func nextButtonTapped() {
        if currentPage < slides.count - 1 {
            currentPage += 1
            updateUI(animated: true)
        } else {
            // ✅ Mark onboarding as done
             UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

             // ✅ Go to login, not home
             guard let window = UIApplication.shared.connectedScenes
                 .compactMap({ $0 as? UIWindowScene })
                 .first?.windows.first else { return }

             let storyboard = UIStoryboard(name: "Main", bundle: nil)
             let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
             let navVC = UINavigationController(rootViewController: loginVC)
             navVC.isNavigationBarHidden = true
             window.rootViewController = navVC
             UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
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
        
        pageControl.currentPage = currentPage
        
        let buttonTitle = (currentPage == slides.count - 1) ? "Get Started" : "Next"
        UIView.transition(with: nextButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.nextButton.setTitle(buttonTitle, for: .normal)
        }, completion: nil)
        
        if animated {
            let isMovingRight = transitionSubtype == .fromRight
            let translationX: CGFloat = isMovingRight ? 50 : -50
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.functionalityPic.alpha = 0
                self.functionalityPic.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
                self.functionalityTitle.alpha = 0
                self.functionalityTitle.transform = CGAffineTransform(translationX: -translationX, y: 0)
                
                self.functionalityDesc.alpha = 0
                self.functionalityDesc.transform = CGAffineTransform(translationX: -translationX, y: 0)
            }) { _ in
                self.functionalityTitle.text = slide.title
                self.functionalityDesc.text = slide.description
                self.functionalityPic.image = UIImage(named: slide.imageName)
                
                self.functionalityTitle.transform = CGAffineTransform(translationX: translationX, y: 0)
                self.functionalityDesc.transform = CGAffineTransform(translationX: translationX, y: 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    self.functionalityPic.alpha = 1
                    self.functionalityPic.transform = .identity
                    
                    self.functionalityTitle.alpha = 1
                    self.functionalityTitle.transform = .identity
                    
                    self.functionalityDesc.alpha = 1
                    self.functionalityDesc.transform = .identity
                }, completion: nil)
            }
        } else {
            functionalityTitle.text = slide.title
            functionalityDesc.text = slide.description
            functionalityPic.image = UIImage(named: slide.imageName)
            
            // Initial animation when view loads
            self.functionalityPic.alpha = 0
            self.functionalityTitle.alpha = 0
            self.functionalityDesc.alpha = 0
            self.functionalityPic.transform = CGAffineTransform(translationX: 0, y: 30)
            self.functionalityTitle.transform = CGAffineTransform(translationX: 0, y: 20)
            self.functionalityDesc.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.functionalityPic.alpha = 1
                self.functionalityPic.transform = .identity
            }, completion: nil)
            
            UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.functionalityTitle.alpha = 1
                self.functionalityTitle.transform = .identity
            }, completion: nil)
            
            UIView.animate(withDuration: 0.6, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                self.functionalityDesc.alpha = 1
                self.functionalityDesc.transform = .identity
            }, completion: nil)
        }
    }
}
