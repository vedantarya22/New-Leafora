import UIKit

class PlantScanningViewController: UIViewController {
    
    private let imageToScan: UIImage
    var onComplete: ((Result<[PlantSuggestion], Error>) -> Void)?
    
    // UI Elements
    private let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let scanningLabel: UILabel = {
        let label = UILabel()
        label.text = "Identifying your plant..."
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Analyzing image with AI"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemMint
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    init(image: UIImage) {
        self.imageToScan = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        previewImageView.image = imageToScan
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start scanning after view is fully presented
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startScanning()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(containerView)
        containerView.addSubview(previewImageView)
        containerView.addSubview(scanningLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            // Preview Image
            previewImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            previewImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            previewImageView.widthAnchor.constraint(equalToConstant: 200),
            previewImageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Scanning Label
            scanningLabel.topAnchor.constraint(equalTo: previewImageView.bottomAnchor, constant: 30),
            scanningLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scanningLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Status Label
            statusLabel.topAnchor.constraint(equalTo: scanningLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            // Activity Indicator
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 25),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }
    
    private func startScanning() {
        activityIndicator.startAnimating()
        print("🔍 Starting plant identification...")
        
        // Call the API
        PlantIdentificationService.shared.identifyPlant(image: imageToScan) { [weak self] result in
            guard let self = self else { return }
            
            print("✅ Received identification result")
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let suggestions):
                print("✅ Found \(suggestions.count) suggestions")
                if let first = suggestions.first {
                    print("✅ Top match: \(first.plantName) (\(Int(first.probability * 100))%)")
                }
                self.showResults(suggestions)
            case .failure(let error):
                print("❌ Identification error: \(error.localizedDescription)")
                self.showError(error)
            }
        }
    }
    
    private func showResults(_ suggestions: [PlantSuggestion]) {
        print("📱 Preparing to show results screen...")
        
        let resultsVC = PlantIdentificationResultsViewController(
            image: imageToScan,
            suggestions: suggestions
        )
        resultsVC.modalPresentationStyle = .fullScreen
        
        print("📱 Dismissing scanning view and presenting results...")
        dismiss(animated: true) { [weak self] in
            print("📱 Scanning view dismissed, now presenting results")
            // Get the root view controller to present from
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                
                // Find the top-most presented view controller
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                print("📱 Presenting from: \(type(of: topVC))")
                topVC.present(resultsVC, animated: true) {
                    print("✅ Results view controller presented successfully")
                }
            } else {
                print("❌ ERROR: Could not find window or root view controller")
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Identification Failed",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
