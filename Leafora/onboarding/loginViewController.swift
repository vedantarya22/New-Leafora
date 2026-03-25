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

        if let cachedEmail = UserDefaults.standard.string(forKey: "cachedUserEmail") {
            usernameTextField.text = cachedEmail
        }
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup
    private func setupUI() {
        setupGestures()
        passwordTextField.isSecureTextEntry  = true
        usernameTextField.keyboardType       = .emailAddress
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        styleTextField(usernameTextField)
        styleTextField(passwordTextField)
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
        styleButtons()

        let fullText = "Don't have an account? Sign Up"
        let attr     = NSMutableAttributedString(string: fullText)
        let range    = (fullText as NSString).range(of: "Sign Up")
        attr.addAttribute(.foregroundColor, value: UIColor.secondaryLabel,
                          range: NSRange(location: 0, length: fullText.count))
        attr.addAttribute(.foregroundColor,
                          value: UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0),
                          range: range)
        attr.addAttribute(.font,
                          value: UIFont.boldSystemFont(ofSize: signUpLabel.font.pointSize),
                          range: range)
        signUpLabel.attributedText = attr
    }

    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSignUpTap))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tap)

        // dismiss keyboard on outside tap
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Login
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email    = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter email and password")
            return
        }

        errorLabel.isHidden = true
        loginButton.isEnabled = false

        NetworkManager.shared.login(email: email, password: password) { [weak self] success, message in
            guard let self = self else { return }
            self.loginButton.isEnabled = true
            if success {
                UserDefaults.standard.set(email, forKey: "cachedUserEmail")
                self.showSuccessFlash(message: "Login Successful") {
                    self.navigateToMainApp()
                }
            } else {
                self.showError(message ?? "Login failed")
            }
        }
    }

    @objc private func handleSignUpTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signupVC = storyboard.instantiateViewController(
            withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signupVC, animated: true)
        }
    }

    // MARK: - Navigation
    private func navigateToMainApp() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else { return }

        // switch to main app UI
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)

        // load data after navigation
        sceneDelegate.loadAppData()
    }

    // MARK: - UI Helpers
    private func showError(_ message: String) {
        errorLabel.text     = message
        errorLabel.isHidden = false
    }

    private func styleTextField(_ textField: UITextField) {
        textField.backgroundColor    = .white
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.layer.borderWidth  = 1
        textField.layer.borderColor  = UIColor.systemGray5.cgColor
        let pad = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftView     = pad
        textField.leftViewMode = .always
    }

    private func styleButtons() {
        let green = UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0)

        loginButton.tintColor = green
        if #available(iOS 15.0, *) {
            loginButton.configuration?.baseBackgroundColor = green
        } else {
            loginButton.backgroundColor = green
        }

        googleButton.tintColor = .black
        if #available(iOS 15.0, *) {
            googleButton.configuration?.baseBackgroundColor  = .white
            googleButton.configuration?.baseForegroundColor = .black
        } else {
            googleButton.backgroundColor = .white
            googleButton.setTitleColor(.black, for: .normal)
        }

        appleButton.tintColor = .white
        if #available(iOS 15.0, *) {
            appleButton.configuration?.baseBackgroundColor  = .black
            appleButton.configuration?.baseForegroundColor = .white
        } else {
            appleButton.backgroundColor = .black
            appleButton.setTitleColor(.white, for: .normal)
        }
    }
}
