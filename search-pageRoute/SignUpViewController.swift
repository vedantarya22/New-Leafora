import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!

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
            $0?.autocapitalizationType = .none
            $0?.autocorrectionType = .no
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
                self?.navigateToMainApp()
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
