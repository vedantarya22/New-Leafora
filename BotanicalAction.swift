import UIKit

// MARK: - Action Model
struct BotanicalAction {
    let title: String
    let style: BotanicalActionStyle
    let handler: (() -> Void)?
    
    init(title: String, style: BotanicalActionStyle = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

enum BotanicalActionStyle {
    case `default`
    case destructive
    case cancel
}

// MARK: - Custom Action Sheet
class BotanicalActionSheet: UIViewController {
    
    // MARK: - Properties
    private let sheetTitle: String?
    private let message: String?
    private let actions: [BotanicalAction]
    
    private let gradientLayer = CAGradientLayer()
    private let containerView = UIView()
    private let handleBar = UIView()
    private let stackView = UIStackView()
    private let dimView = UIView()
    
    // MARK: - Init
    init(title: String? = nil, message: String? = nil, actions: [BotanicalAction]) {
        self.sheetTitle = title
        self.message = message
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDimView()
        setupContainer()
        setupHandleBar()
        setupContent()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
    
    // MARK: - Setup
    private func setupDimView() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSheet))
        dimView.addGestureRecognizer(tap)
    }
    
    private func setupContainer() {
        // Gradient background matching app theme
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.layer.cornerRadius = 28
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.masksToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.transform = CGAffineTransform(translationX: 0, y: 400)
        
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupHandleBar() {
        handleBar.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.35)
        handleBar.layer.cornerRadius = 3
        handleBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(handleBar)
        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    private func setupContent() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        // Title
        if let title = sheetTitle {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = UIColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 1)
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let titleContainer = UIView()
            titleContainer.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: titleContainer.topAnchor, constant: 20),
                titleLabel.bottomAnchor.constraint(equalTo: titleContainer.bottomAnchor, constant: -8),
                titleLabel.leadingAnchor.constraint(equalTo: titleContainer.leadingAnchor, constant: 24),
                titleLabel.trailingAnchor.constraint(equalTo: titleContainer.trailingAnchor, constant: -24)
            ])
            stackView.addArrangedSubview(titleContainer)
        }
        
        // Message
        if let message = message {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            messageLabel.textColor = .secondaryLabel
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let msgContainer = UIView()
            msgContainer.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: msgContainer.topAnchor, constant: 4),
                messageLabel.bottomAnchor.constraint(equalTo: msgContainer.bottomAnchor, constant: -16),
                messageLabel.leadingAnchor.constraint(equalTo: msgContainer.leadingAnchor, constant: 24),
                messageLabel.trailingAnchor.constraint(equalTo: msgContainer.trailingAnchor, constant: -24)
            ])
            stackView.addArrangedSubview(msgContainer)
        }
        
        // Divider if we have title/message
        if sheetTitle != nil || message != nil {
            let divider = UIView()
            divider.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.15)
            divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            stackView.addArrangedSubview(divider)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupButtons() {
        let nonCancel = actions.filter { $0.style != .cancel }
        let cancel = actions.filter { $0.style == .cancel }
        
        for (index, action) in nonCancel.enumerated() {
            let button = makeButton(for: action)
            stackView.addArrangedSubview(button)
            
            // Divider between buttons (not after last)
            if index < nonCancel.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.1)
                divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(divider)
            }
        }
        
        // Cancel button with gap
        if let cancelAction = cancel.first {
            let spacer = UIView()
            spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
            spacer.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.08)
            stackView.addArrangedSubview(spacer)
            stackView.addArrangedSubview(makeButton(for: cancelAction))
        }
    }
    
    private func makeButton(for action: BotanicalAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        switch action.style {
        case .default:
            button.setTitleColor(UIColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        case .destructive:
            button.setTitleColor(.systemRed, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        case .cancel:
            button.setTitleColor(UIColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
        
        button.backgroundColor = .clear
        
        // Highlight on tap
        button.addTarget(self, action: #selector(buttonHighlight(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonUnhighlight(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        // Store action via tag trick using objc association
        objc_setAssociatedObject(button, &AssociatedKeys.action, action, .OBJC_ASSOCIATION_RETAIN)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // MARK: - Animations
    private func animateIn() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.containerView.transform = .identity
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    
    @objc private func dismissSheet() {
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 400)
            self.dimView.backgroundColor = .clear
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Button Actions
    @objc private func buttonHighlight(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.08)
        }
    }
    
    @objc private func buttonUnhighlight(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.backgroundColor = .clear
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let action = objc_getAssociatedObject(sender, &AssociatedKeys.action) as? BotanicalAction else { return }
        dismissSheet()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            action.handler?()
        }
    }
}

// MARK: - Associated Keys
private struct AssociatedKeys {
    static var action = "action"
}