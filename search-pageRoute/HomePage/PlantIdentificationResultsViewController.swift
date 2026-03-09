import UIKit

class PlantIdentificationResultsViewController: UIViewController {
    
    private let plantImage: UIImage
    private let suggestions: [PlantSuggestion]
    
    // UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confidenceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemMint
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commonNamesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "About This Plant"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taxonomyTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Classification"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taxonomyStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let otherMatchesLabel: UILabel = {
        let label = UILabel()
        label.text = "Other Possible Matches"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otherMatchesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let goToPlantButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Plant", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemMint
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(image: UIImage, suggestions: [PlantSuggestion]) {
        self.plantImage = image
        self.suggestions = suggestions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(confidenceLabel)
        contentView.addSubview(commonNamesLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(taxonomyTitleLabel)
        contentView.addSubview(taxonomyStackView)
        contentView.addSubview(otherMatchesLabel)
        contentView.addSubview(otherMatchesStackView)
        contentView.addSubview(goToPlantButton)
        
        goToPlantButton.addTarget(self, action: #selector(goToPlantTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Image
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 280),
            imageView.heightAnchor.constraint(equalToConstant: 280),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Confidence
            confidenceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            confidenceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confidenceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Common Names
            commonNamesLabel.topAnchor.constraint(equalTo: confidenceLabel.bottomAnchor, constant: 8),
            commonNamesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            commonNamesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description Title
            descriptionTitleLabel.topAnchor.constraint(equalTo: commonNamesLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Taxonomy Title
            taxonomyTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            taxonomyTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taxonomyTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Taxonomy Stack
            taxonomyStackView.topAnchor.constraint(equalTo: taxonomyTitleLabel.bottomAnchor, constant: 8),
            taxonomyStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taxonomyStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Other Matches Title
            otherMatchesLabel.topAnchor.constraint(equalTo: taxonomyStackView.bottomAnchor, constant: 24),
            otherMatchesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherMatchesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Other Matches Stack
            otherMatchesStackView.topAnchor.constraint(equalTo: otherMatchesLabel.bottomAnchor, constant: 8),
            otherMatchesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherMatchesStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Go to Plant Button
            goToPlantButton.topAnchor.constraint(equalTo: otherMatchesStackView.bottomAnchor, constant: 30),
            goToPlantButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            goToPlantButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            goToPlantButton.heightAnchor.constraint(equalToConstant: 50),
            goToPlantButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func populateData() {
        guard let topSuggestion = suggestions.first else { return }
        
        // Set image
        imageView.image = plantImage
        
        // Set title (scientific name)
        titleLabel.text = topSuggestion.plantName
        
        // Set confidence
        let percentage = Int(topSuggestion.probability * 100)
        confidenceLabel.text = "\(percentage)% Match"
        
        // Set common names
        if let commonNames = topSuggestion.plantDetails?.commonNames, !commonNames.isEmpty {
            commonNamesLabel.text = "Also known as: " + commonNames.joined(separator: ", ")
        } else {
            commonNamesLabel.isHidden = true
        }
        
        // Set description
        if let description = topSuggestion.plantDetails?.description?.value {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = "No description available."
        }
        
        // Set taxonomy
        if let taxonomy = topSuggestion.plantDetails?.taxonomy {
            addTaxonomyRow(label: "Family", value: taxonomy.family)
            addTaxonomyRow(label: "Genus", value: taxonomy.genus)
            addTaxonomyRow(label: "Class", value: taxonomy.class)
        } else {
            taxonomyTitleLabel.isHidden = true
            taxonomyStackView.isHidden = true
        }
        
        // Set other matches
        if suggestions.count > 1 {
            for i in 1..<min(suggestions.count, 4) {
                let suggestion = suggestions[i]
                addOtherMatchRow(suggestion: suggestion)
            }
        } else {
            otherMatchesLabel.isHidden = true
            otherMatchesStackView.isHidden = true
        }
    }
    
    private func addTaxonomyRow(label: String, value: String?) {
        guard let value = value else { return }
        
        let rowView = UIView()
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let keyLabel = UILabel()
        keyLabel.text = label
        keyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        keyLabel.textColor = .secondaryLabel
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rowView.addSubview(keyLabel)
        rowView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            keyLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
            keyLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            keyLabel.widthAnchor.constraint(equalToConstant: 80),
            
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: rowView.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor)
        ])
        
        taxonomyStackView.addArrangedSubview(rowView)
    }
    
    private func addOtherMatchRow(suggestion: PlantSuggestion) {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = suggestion.plantName
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let probabilityLabel = UILabel()
        let percentage = Int(suggestion.probability * 100)
        probabilityLabel.text = "\(percentage)%"
        probabilityLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        probabilityLabel.textColor = .systemMint
        probabilityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(probabilityLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            nameLabel.trailingAnchor.constraint(equalTo: probabilityLabel.leadingAnchor, constant: -12),
            
            probabilityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            probabilityLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        otherMatchesStackView.addArrangedSubview(containerView)
    }
    
    @objc private func goToPlantTapped() {
        guard let topSuggestion = suggestions.first else {
            showPlantNotFoundAlert()
            return
        }
        
        // Load all plants from JSON
        let allPlants = JSONLoader.loadPlants(from: "plantData")
        
        // Try to find a matching plant by comparing scientific name, common name, and API common names
        let topNameLower = topSuggestion.plantName.lowercased()
        
        let matchingPlant = allPlants.first { plant in
            let localPlantNameLower = plant.plantName.lowercased()
            let localSciNameLower = plant.scientificName.lowercased()
            
            // 1. Direct name match
            if localPlantNameLower == topNameLower || localSciNameLower == topNameLower {
                return true
            }
            // 2. Contains match (scientific names can be long e.g. "Aloe barbadensis miller" vs "Aloe")
            if localSciNameLower.contains(topNameLower) || topNameLower.contains(localSciNameLower) {
                return true
            }
            
            // 3. Match against the common names array returned by the API
            if let apiCommonNames = topSuggestion.plantDetails?.commonNames {
                for apiName in apiCommonNames {
                    let apiNameLower = apiName.lowercased()
                    if apiNameLower == localPlantNameLower || localPlantNameLower.contains(apiNameLower) {
                        return true
                    }
                }
            }
            
            return false
        }
        
        if let foundPlant = matchingPlant {
            // Plant exists in JSON - navigate to PlantDetailViewController
            print("✅ Plant found in JSON: \(foundPlant.plantName)")
            navigateToPlantDetail(plantId: foundPlant.plantId)
        } else {
            // Plant not found in JSON
            print("❌ Plant not found in JSON: \(topSuggestion.plantName)")
            showPlantNotFoundAlert()
        }
    }
    
    private func navigateToPlantDetail(plantId: String) {
        dismiss(animated: true) {
            // Navigate to PlantDetailViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let plantDetailVC = storyboard.instantiateViewController(withIdentifier: "PlantDetailViewController") as? PlantDetailViewController {
                plantDetailVC.plantId = plantId
                
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first,
                      let rootVC = window.rootViewController else { return }
                      
                var topVC = rootVC
                while let presented = topVC.presentedViewController {
                    topVC = presented
                }
                
                if let tabBarController = topVC as? UITabBarController {
                    if let navController = tabBarController.selectedViewController as? UINavigationController {
                        navController.pushViewController(plantDetailVC, animated: true)
                    } else if let selected = tabBarController.selectedViewController, let navController = selected.navigationController {
                        navController.pushViewController(plantDetailVC, animated: true)
                    } else {
                        // Present modally as a last resort if no navigation controller exists
                        plantDetailVC.modalPresentationStyle = .fullScreen
                        tabBarController.selectedViewController?.present(plantDetailVC, animated: true)
                    }
                } else if let navController = topVC as? UINavigationController {
                    navController.pushViewController(plantDetailVC, animated: true)
                } else if let navController = topVC.navigationController {
                    navController.pushViewController(plantDetailVC, animated: true)
                } else {
                    plantDetailVC.modalPresentationStyle = .fullScreen
                    topVC.present(plantDetailVC, animated: true)
                }
            }
        }
    }
    
    private func showPlantNotFoundAlert() {
        let alert = UIAlertController(
            title: "Plant Not Available",
            message: "This plant is not currently in our database. We're continuously adding new plants!",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Back to Home", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                // Dismiss back to home screen
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    
                    // Dismiss all presented view controllers to go back to root
                    rootVC.dismiss(animated: true)
                }
            }
        })
        
        present(alert, animated: true)
    }

}
