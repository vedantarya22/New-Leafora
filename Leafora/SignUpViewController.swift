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
        label.textColor     = .systemRed
        label.font          = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden      = true
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
    
    @IBAction func googleButtonTapped(_ sender: UIButton) {
        errorLabel.isHidden = true
           sender.isEnabled = false

           GoogleAuthManager.shared.signIn(presenting: self) { [weak self] success, message in
               guard let self = self else { return }
               sender.isEnabled = true
               if success {
                   self.navigateToMainApp()
               } else {
                   self.showError(message ?? "Google sign-in failed")
               }
           }
    }
    

    // MARK: - Setup
    private func setupUI() {
        passwordTextField.isSecureTextEntry = true
        passwordTextField.enablePasswordToggle()
        emailTextField.keyboardType         = .emailAddress
        [nameTextField, usernameTextField, emailTextField, passwordTextField].forEach {
            $0?.autocapitalizationType = .none
            $0?.autocorrectionType    = .no
            if let tf = $0 { styleTextField(tf) }
        }
        signupButton.layer.cornerRadius = 10
        signupButton.clipsToBounds = true
        styleButtons()
        setupLoginLabelGesture()
    }

    private func setupLoginLabelGesture() {
        func findLabel(in view: UIView) {
            for subview in view.subviews {
                if let label = subview as? UILabel,
                   label.text?.contains("Already") == true {
                    label.isUserInteractionEnabled = true
                    label.addGestureRecognizer(
                        UITapGestureRecognizer(target: self, action: #selector(handleLoginTap))
                    )
                    let fullText = "Already have an account? Log in"
                    let attr     = NSMutableAttributedString(string: fullText)
                    let range    = (fullText as NSString).range(of: "Log in")
                    attr.addAttribute(.foregroundColor, value: UIColor.systemGray2,
                                      range: NSRange(location: 0, length: fullText.count))
                    attr.addAttribute(.foregroundColor,
                                      value: UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0),
                                      range: range)
                    attr.addAttribute(.font,
                                      value: UIFont.boldSystemFont(ofSize: label.font.pointSize),
                                      range: range)
                    label.attributedText = attr
                    return
                }
                findLabel(in: subview)
            }
        }
        findLabel(in: view)
    }

    @objc private func handleLoginTap() {
        if navigationController != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
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

    // MARK: - Signup
    /// Storyboard action alias — forwards to signupButtonTapped
    @IBAction func signupButton(_ sender: UIButton) { signupButtonTapped(sender) }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let name     = nameTextField.text,     !name.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let email    = emailTextField.text,    !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please fill in all fields")
            return
        }

        errorLabel.isHidden   = true
        sender.isEnabled = false

        NetworkManager.shared.signup(
            name: name, username: username,
            email: email, password: password
        ) { [weak self] success, message in
            DispatchQueue.main.async {
                sender.isEnabled = true
                if success {
                    print(" Signup success, userId: \(UserSession.shared.currentLoggedInUserID)")
                    self?.navigateToMainApp()
                } else {
                    self?.showError(message ?? "Signup failed")
                }
            }
        }
    }

    // MARK: - Navigation
    private func navigateToMainApp() {
        DispatchQueue.main.async {
            print("✅ navigateToMainApp called on main thread: \(Thread.isMainThread)")
            let onboardingStoryboard = UIStoryboard(name: "onboarding", bundle: nil)
            let vc = onboardingStoryboard.instantiateViewController(withIdentifier: "ProfilePicturePromptVC")
            print("✅ Instantiated VC: \(vc)")
            guard let promptVC = vc as? ProfilePicturePromptViewController else {
                print("⚠️ Cast failed, falling back to direct main navigation")
                self.navigateDirectlyToMain()
                return
            }
            promptVC.modalPresentationStyle = .fullScreen
            promptVC.modalTransitionStyle   = .crossDissolve
            self.present(promptVC, animated: true) {
                print("✅ ProfilePicturePromptVC presented successfully")
            }
        }
    }

    private func navigateDirectlyToMain() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
        sceneDelegate.loadAppData()
    }

    // MARK: - UI Helpers
    private func showError(_ message: String) {
        errorLabel.text     = message
        errorLabel.isHidden = false
    }

    private func styleTextField(_ textField: UITextField) {
        textField.backgroundColor     = .white
        textField.layer.cornerRadius  = 10
        textField.layer.masksToBounds = true
        textField.layer.borderWidth   = 1
        textField.layer.borderColor   = UIColor.systemGray5.cgColor
        
        // Set placeholder color to systemGray2 for better visibility
        if let placeholder = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.systemGray2]
            )
        }
        
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView     = pad
        textField.leftViewMode = .always
    }

    private func styleButtons() {
        let green = UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0)

        signupButton.tintColor = green
        if #available(iOS 15.0, *) {
            signupButton.configuration?.baseBackgroundColor = green
        } else {
            signupButton.backgroundColor = green
        }

        if let gBtn = googleButton {
            gBtn.tintColor = .black
            if #available(iOS 15.0, *) {
                gBtn.configuration?.baseBackgroundColor  = .white
                gBtn.configuration?.baseForegroundColor = .black
            } else {
                gBtn.backgroundColor = .white
                gBtn.setTitleColor(.black, for: .normal)
            }
        }

        if let aBtn = appleButton {
            aBtn.tintColor = .white
            if #available(iOS 15.0, *) {
                aBtn.configuration?.baseBackgroundColor  = .black
                aBtn.configuration?.baseForegroundColor = .white
            } else {
                aBtn.backgroundColor = .black
                aBtn.setTitleColor(.white, for: .normal)
            }
        }
    }
}
