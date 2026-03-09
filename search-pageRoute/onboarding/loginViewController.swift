import UIKit

class loginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!  // ✅ used as email field
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var signUpLabel: UILabel!

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
        setupGestures()
        passwordTextField.isSecureTextEntry = true
        usernameTextField.keyboardType = .emailAddress
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSignUpTap))
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(tapGesture)
    }

    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError("Please enter email and password")
            return
        }

        loginButton.isEnabled = false

        NetworkManager.shared.login(email: email, password: password) { [weak self] success, message in
            self?.loginButton.isEnabled = true
            if success {
                self?.navigateToMainApp()
            } else {
                self?.showError(message ?? "Login failed")
            }
        }
    }

    @objc private func handleSignUpTap() {
        // ✅ Navigate to signup screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  // ✅ replace with your signup storyboard name
        if let signupVC = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signupVC, animated: true)
        }
    }

    // MARK: - Error
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    // MARK: - Navigation
    private func navigateToMainApp() {
        // ✅ Load app data first then navigate
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.loadAppData()
        }

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        let storyboardName = hasSeenOnboarding ? "Main" : "onboarding"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first
        else { return }

        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
    }
}
