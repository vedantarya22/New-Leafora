//
//  TipArticleViewController.swift
//  homescreen1
//
//  In-app article screen shown when a Garden Tip card is tapped.
//  Push-navigated from HomeViewController via the nav controller.
//  Storyboard ID: "TipArticleViewController"
//

import UIKit

class TipArticleViewController: UIViewController {

    // MARK: - Public input (set before push)
    var tip: GardenTip!

    // MARK: - IBOutlets  (wire these in Storyboard — see layout guide below)
    @IBOutlet weak var heroImageView:   UIImageView!
    @IBOutlet weak var scrollView:      UIScrollView!
    @IBOutlet weak var contentView:     UIView!          // scroll view's content view
    @IBOutlet weak var pillView:        UIView!
    @IBOutlet weak var pillIconView:    UIImageView!
    @IBOutlet weak var pillLabel:       UILabel!
    @IBOutlet weak var articleTitle:    UILabel!
    @IBOutlet weak var tipQuoteLabel:   UILabel!         // the original short tip in a quote block
    @IBOutlet weak var quoteBar:        UIView!          // left green accent bar beside quote
    @IBOutlet weak var bodyLabel:       UILabel!
    @IBOutlet weak var benefitTitle:    UILabel!         // "Why This Matters"
    @IBOutlet weak var benefitLabel:    UILabel!
    @IBOutlet weak var sourceButton:    UIButton!

    // MARK: - Gradient / background
    private let gradientLayer = CAGradientLayer()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavigationBar()
        populateContent()
        styleViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Background (matches HomeViewController botanical gradient)
    private func setupBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor,
            UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradientLayer.frame      = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Garden Tip"

        // Transparent nav bar so hero image bleeds under it
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)

        // Custom back button label
        navigationItem.backButtonTitle = "Home"
    }

    // MARK: - Populate
    private func populateContent() {
        guard tip != nil else { return }

        // Hero image
        if let name = tip.imageName, let img = UIImage(named: name) {
            heroImageView.image = img
        } else {
            heroImageView.image           = UIImage(systemName: "leaf.fill")
            heroImageView.tintColor       = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
            heroImageView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 1.0)
        }

        // Pill
        pillLabel.text = "GARDEN TIP"
        pillIconView.image     = UIImage(systemName: "leaf.fill")
        pillIconView.tintColor = .white

        // Title (the short tip becomes the headline)
        articleTitle.text = tip.title

        // Quote block — the original one-liner tip
        tipQuoteLabel.text = tip.message

        // Full article body
        bodyLabel.text = tip.articleBody

        // Benefit section
        benefitTitle.text = "Why This Matters"
        benefitLabel.text = tip.benefitText

        // Source button
        let host = URL(string: tip.sourceURL)?.host ?? "gardeningknowhow.com"
        var config = UIButton.Configuration.filled()
        config.title               = "Read Full Article on \(host)"
        config.image               = UIImage(systemName: "arrow.up.right.square")
        config.imagePlacement      = .trailing
        config.imagePadding        = 6
        config.baseBackgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        config.baseForegroundColor = .white
        config.cornerStyle         = .large
        sourceButton.configuration = config
    }

    // MARK: - Styling
    private func styleViews() {
        // Hero
        heroImageView.contentMode   = .scaleAspectFill
        heroImageView.clipsToBounds = true

        // Gradient fade over bottom of hero image
        DispatchQueue.main.async {
            let fade = CAGradientLayer()
            fade.colors = [
                UIColor.clear.cgColor,
                UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
            ]
            fade.locations  = [0.55, 1.0]
            fade.startPoint = CGPoint(x: 0.5, y: 0)
            fade.endPoint   = CGPoint(x: 0.5, y: 1)
            fade.frame      = self.heroImageView.bounds
            self.heroImageView.layer.addSublayer(fade)
        }

        // Pill
        pillView.backgroundColor    = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        pillView.layer.cornerRadius = 12
        pillView.clipsToBounds      = true
        pillLabel.font      = .systemFont(ofSize: 11, weight: .bold)
        pillLabel.textColor = .white

        // Article title
        articleTitle.font          = .systemFont(ofSize: 24, weight: .bold)
        articleTitle.textColor     = UIColor(red: 0.10, green: 0.18, blue: 0.10, alpha: 1.0)
        articleTitle.numberOfLines = 0

        // Quote bar (left green accent)
        quoteBar.backgroundColor    = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        quoteBar.layer.cornerRadius = 2

        // Quote text (the original tip)
        tipQuoteLabel.font          = .italicSystemFont(ofSize: 16)
        tipQuoteLabel.textColor     = UIColor(red: 0.20, green: 0.40, blue: 0.25, alpha: 1.0)
        tipQuoteLabel.numberOfLines = 0
        tipQuoteLabel.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 0.6)
        tipQuoteLabel.layer.cornerRadius = 10
        tipQuoteLabel.clipsToBounds      = true

        // Body
        bodyLabel.font          = .systemFont(ofSize: 15, weight: .regular)
        bodyLabel.textColor     = UIColor(red: 0.15, green: 0.22, blue: 0.15, alpha: 1.0)
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping

        // Benefit title
        benefitTitle.font      = .systemFont(ofSize: 17, weight: .semibold)
        benefitTitle.textColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)

        // Benefit body
        benefitLabel.font          = .systemFont(ofSize: 15, weight: .regular)
        benefitLabel.textColor     = UIColor(red: 0.15, green: 0.22, blue: 0.15, alpha: 1.0)
        benefitLabel.numberOfLines = 0

        // Scroll view
        scrollView.backgroundColor   = .clear
        contentView.backgroundColor  = .clear
    }

    // MARK: - Source Button Action
    @IBAction func sourceButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: tip.sourceURL) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
