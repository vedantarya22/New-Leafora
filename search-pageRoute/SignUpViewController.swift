import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!

    private let gradientLayer = CAGradientLayer.backgroundGreen()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        setupUI()
        setupErrorLabel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        emailTextField.keyboardType = .emailAddress
        [nameTextField, usernameTextField, emailTextField, passwordTextField].forEach {
            if let tf = $0 {
                tf.autocapitalizationType = .none
                tf.autocorrectionType = .no
                styleTextField(tf)
            }
        }
        signupButton.layer.cornerRadius = 10
        signupButton.clipsToBounds = true
        styleButtons()
        setupLoginLabelGesture()
    }
    
    private func setupLoginLabelGesture() {
        func findLabel(in view: UIView) {
            for subview in view.subviews {
                if let label = subview as? UILabel, label.text?.contains("Already") == true {
                    label.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoginTap))
                    label.addGestureRecognizer(tapGesture)
                    
                    // Attributed string
                    let fullText = "Already have an account? Log in"
                    let attributedString = NSMutableAttributedString(string: fullText)
                    let loginRange = (fullText as NSString).range(of: "Log in")
                    attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: fullText.count))
                    attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0), range: loginRange)
                    attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: label.font.pointSize), range: loginRange)
                    label.attributedText = attributedString
                    return
                }
                findLabel(in: subview)
            }
        }
        findLabel(in: view)
    }

    @objc private func handleLoginTap() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - UI Helpers
    private func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        
        // Subtle native border
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        
        // Horizontal padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
    
    private func styleButtons() {
        let botanicalGreen = UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0)
        
        // Signup Button
        signupButton.tintColor = botanicalGreen
        if #available(iOS 15.0, *) {
            signupButton.configuration?.baseBackgroundColor = botanicalGreen
        } else {
            signupButton.backgroundColor = botanicalGreen
        }
        
        // Google Button
        if let gBtn = googleButton {
            gBtn.tintColor = .black
            if #available(iOS 15.0, *) {
                gBtn.configuration?.baseBackgroundColor = .white
                gBtn.configuration?.baseForegroundColor = .black
            } else {
                gBtn.backgroundColor = .white
                gBtn.setTitleColor(.black, for: .normal)
            }
        }
        
        // Apple button
        if let aBtn = appleButton {
            aBtn.tintColor = .white
            if #available(iOS 15.0, *) {
                aBtn.configuration?.baseBackgroundColor = .black
                aBtn.configuration?.baseForegroundColor = .white
            } else {
                aBtn.backgroundColor = .black
                aBtn.setTitleColor(.white, for: .normal)
            }
        }
    }

    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: signupButton.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Actions
    @IBAction func signupButton(_ sender: Any) {
        guard let name     = nameTextField.text,     !name.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let email    = emailTextField.text,    !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please fill in all fields")
            return
        }

        // ✅ Disable button to prevent double tap
        if let button = sender as? UIButton { button.isEnabled = false }

        NetworkManager.shared.signup(
            name:     name,
            username: username,
            email:    email,
            password: password
        ) { [weak self] success, message in
            if let button = sender as? UIButton { button.isEnabled = true }

            if success {
                print("✅ Signup success")
                let alert = UIAlertController(title: "Account Created!", message: "Please log in with your new credentials.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if let nav = self?.navigationController {
                        nav.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true)
                    }
                }))
                self?.present(alert, animated: true)
            } else {
                self?.showError(message ?? "Signup failed")
            }
        }
    }

    // MARK: - Error
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    // MARK: - Navigation
    private func navigateToMainApp() {
        // ✅ Load app data in background
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.loadAppData()
        }

        // ✅ New user → always show onboarding first
        let storyboard = UIStoryboard(name: "onboarding", bundle: nil)

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first
        else { return }

        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
}
