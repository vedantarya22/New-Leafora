import UIKit

class TutorialOverlayView: UIView {
    
    private let backgroundDimmer = UIView()
    private let speechBubble = UIView()
    private let messageLabel = UILabel()
    private let arrowImageView = UIImageView()
    private var dismissHandler: (() -> Void)?
    
    init(frame: CGRect, dismissHandler: @escaping () -> Void) {
        self.dismissHandler = dismissHandler
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 1. Background Dimmer
        backgroundDimmer.frame = bounds
        backgroundDimmer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        backgroundDimmer.alpha = 0
        addSubview(backgroundDimmer)
        
        // 2. Speech Bubble
        speechBubble.backgroundColor = .white
        speechBubble.layer.cornerRadius = 16
        speechBubble.layer.shadowColor = UIColor.black.cgColor
        speechBubble.layer.shadowOpacity = 0.2
        speechBubble.layer.shadowOffset = CGSize(width: 0, height: 4)
        speechBubble.layer.shadowRadius = 10
        speechBubble.translatesAutoresizingMaskIntoConstraints = false
        speechBubble.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        speechBubble.alpha = 0
        addSubview(speechBubble)
        
        // 3. Message Label
        messageLabel.text = "Start Your Botanical Journey!"
        let subtitle = "\n\nTap here to add your first plant and begin filling your garden with life."
        let attributedText = NSMutableAttributedString(string: messageLabel.text!, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
        attributedText.append(NSAttributedString(string: subtitle, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)]))
        
        messageLabel.attributedText = attributedText
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor(red: 0.15, green: 0.35, blue: 0.15, alpha: 1.0)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        speechBubble.addSubview(messageLabel)
        
        // 4. Arrow
        arrowImageView.image = UIImage(systemName: "arrow.down.circle.fill")
        arrowImageView.tintColor = .white
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.alpha = 0
        addSubview(arrowImageView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Bubble position (above the tab bar)
            speechBubble.centerXAnchor.constraint(equalTo: centerXAnchor),
            speechBubble.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -180),
            speechBubble.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            
            messageLabel.topAnchor.constraint(equalTo: speechBubble.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: speechBubble.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: speechBubble.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: speechBubble.bottomAnchor, constant: -20),
            
            // Arrow position (pointing to the Add tab)
            arrowImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: bounds.width * 0.35), 
            arrowImageView.topAnchor.constraint(equalTo: speechBubble.bottomAnchor, constant: 12),
            arrowImageView.widthAnchor.constraint(equalToConstant: 50),
            arrowImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Tap to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissTutorial))
        addGestureRecognizer(tap)
    }
    
    func show() {
        UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.backgroundDimmer.alpha = 1
            self.speechBubble.alpha = 1
            self.speechBubble.transform = .identity
            self.arrowImageView.alpha = 1
        }, completion: { _ in
            self.startAnimations()
        })
    }
    
    private func startAnimations() {
        // Pulse animation for bubble
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.speechBubble.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }, completion: nil)
        
        // Bounce animation for arrow
        let bounce = CABasicAnimation(keyPath: "transform.translation.y")
        bounce.duration = 0.6
        bounce.repeatCount = .infinity
        bounce.autoreverses = true
        bounce.fromValue = 0
        bounce.toValue = 15
        arrowImageView.layer.add(bounce, forKey: "arrowBounce")
    }
    
    @objc private func dismissTutorial() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            self.dismissHandler?()
        }
    }
}
