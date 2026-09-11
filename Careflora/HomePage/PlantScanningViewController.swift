import UIKit

class PlantScanningViewController: UIViewController {
    
    var imageToScan: UIImage!
    var onComplete: ((Result<[PlantSuggestion], Error>) -> Void)?
    
    // MARK: - IBOutlets (connected in PlantIdentification.storyboard)
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var scanningLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Style the container card
        containerView.layer.cornerCurve = .continuous
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.15
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOffset = CGSize(width: 0, height: 10)
        
        // Style the image
        previewImageView.layer.cornerCurve = .continuous
        previewImageView.layer.borderWidth = 3
        previewImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Set image
        previewImageView.image = imageToScan
        
        // Subtle pulse animation
        UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
            self.previewImageView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
            self.previewImageView.alpha = 0.85
        } completion: { _ in }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startScanning()
        }
    }
    
    // MARK: - Scanning
    private func startScanning() {
        activityIndicator.startAnimating()
        print("🔍 Starting plant identification...")
        
        PlantIdentificationService.shared.identifyPlant(image: imageToScan) { [weak self] result in
            guard let self = self else { return }
            
            print(" Received identification result")
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let suggestions):
                print(" Found \(suggestions.count) suggestions")
                if let first = suggestions.first {
                    print(" Top match: \(first.plantName) (\(Int(first.probability * 100))%)")
                }
                self.showResults(suggestions)
            case .failure(let error):
                print(" Identification error: \(error.localizedDescription)")
                self.showError(error)
            }
        }
    }
    
    private func showResults(_ suggestions: [PlantSuggestion]) {
        print(" Preparing to show results screen...")

        // If top suggestion confidence is below 20%, treat as not a plant
        if let top = suggestions.first, top.probability < 0.20 {
            let alert = UIAlertController(
                title: "Not Identified",
                message: "We couldn't identify a plant in this image. Please try again with a clearer photo of the plant.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "PlantIdentification", bundle: nil)
        let resultsVC = storyboard.instantiateViewController(withIdentifier: "PlantIdentificationResultsViewController") as! PlantIdentificationResultsViewController
        resultsVC.plantImage = imageToScan
        resultsVC.suggestions = suggestions
        resultsVC.modalPresentationStyle = .fullScreen
        
        print(" Dismissing scanning view and presenting results...")
        dismiss(animated: true) { [weak self] in
            print(" Scanning view dismissed, now presenting results")
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                print(" Presenting from: \(type(of: topVC))")
                topVC.present(resultsVC, animated: true) {
                    print(" Results view controller presented successfully")
                }
            } else {
                print(" ERROR: Could not find window or root view controller")
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
