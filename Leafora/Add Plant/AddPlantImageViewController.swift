import Foundation
import PhotosUI
import UIKit

class AddPlantImageViewController: UIViewController,
                                  UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                  UITextViewDelegate, PHPickerViewControllerDelegate {
    
    var selectedPlant: Plant?
    var session: PlantQuestionSession!
    let siteStore = SiteStore.shared
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    private let gradientLayer = CAGradientLayer()
    private let borderLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        setupImageTapGesture()
        setupSaveButton()
        
        if session.isEditMode, let existingData = session.imageData, let existingImage = UIImage(data: existingData) {
            plantImageView.layer.cornerRadius = 20
            plantImageView.image = existingImage
            plantImageView.contentMode = .scaleAspectFill
            plantImageView.clipsToBounds = true
            borderLayer.isHidden = true
        } else {
            setupImagePlaceholder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        borderLayer.path = UIBezierPath(roundedRect: plantImageView.bounds, cornerRadius: 20).cgPath
        borderLayer.frame = plantImageView.bounds
    }
    
    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupSaveButton() {
        saveButton.layer.cornerRadius = 14
        saveButton.backgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    func setupImageTapGesture() {
        plantImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImagePickerOptions))
        plantImageView.addGestureRecognizer(tap)
    }
    
    func setupImagePlaceholder() {
        plantImageView.layer.cornerRadius = 16
        plantImageView.backgroundColor = .white
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        plantImageView.image = UIImage(systemName: "camera.fill", withConfiguration: config)
        plantImageView.tintColor = .systemGray3
        
        borderLayer.isHidden = true
    }
    
    @objc func showImagePickerOptions() {
        let alert = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func openGallery() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async {
                if let img = image as? UIImage { self.updateSelectedImage(img) }
            }
        }
    }
    
    func updateSelectedImage(_ image: UIImage) {
        plantImageView.image = image
        plantImageView.contentMode = .scaleAspectFill
        borderLayer.isHidden = true
        session.imageData = image.jpegData(compressionQuality: 0.8)
        print("Image saved in session")
    }
    
    private func uploadImageIfNeeded(_ imageData: Data?, completion: @escaping (String?) -> Void) {
        if let imageData = imageData {
            NetworkManager.shared.uploadImageToCloudinary(imageData) { url in
                completion(url)
            }
        } else {
            let fallbackUrl = PlantCatalogueCache.shared.plants.first(where: {
                $0.plantId == self.session.plantId
            })?.imageName
            print("No user image, using catalogue image: \(fallbackUrl ?? "no url")")
            completion(fallbackUrl)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let siteName = session.siteName,
              let siteIcon = session.siteIcon else {
            print("Missing site info in session")
            return
        }
        
        // ✏️ EDIT MODE
        if session.isEditMode,
           let editingBatchSiteID = session.editingBatchSiteID,
           let editingBatchCreatedAt = session.editingBatchCreatedAt,
           let targetQuantity = session.plantCount {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateKey = formatter.string(from: editingBatchCreatedAt)
            
            let allPlantsInSite = PlantStore.shared.plants(for: editingBatchSiteID)
            let originalBatch = allPlantsInSite.filter {
                $0.plantId == session.plantId &&
                formatter.string(from: $0.createdAt) == dateKey
            }
            
            if originalBatch.isEmpty {
                print("❌ Could not find original batch to edit.")
                return
            }
            
            let plantsToEdit = Array(originalBatch.prefix(targetQuantity))
            for mutPlant in plantsToEdit {
                var updatedPlant = mutPlant
                if updatedPlant.siteName != siteName {
                    if !siteStore.sites.contains(where: { $0.name.lowercased() == siteName.lowercased() }) {
                        siteStore.addSite(name: siteName, icon: siteIcon)
                    }
                    if let newSite = siteStore.sites.first(where: { $0.name == siteName }) {
                        updatedPlant.siteName = siteName
                        updatedPlant.siteID = newSite.id
                    }
                }
                updatedPlant.imageData        = session.imageData
                updatedPlant.lightRequirement = session.plantLight
                updatedPlant.watering         = session.wateringAnswer
                updatedPlant.repotting        = session.repottingAnswer
                updatedPlant.lastWatered      = session.lastWateredDate
                updatedPlant.lastRepotted     = session.lastRepottedDate
                updatedPlant.lastPruned       = session.lastPrunedDate
                updatedPlant.lastFertilized   = session.lastFertilizedDate
                PlantStore.shared.updatePlant(updatedPlant)
            }
            
            print("✅ Batch edit complete. Edited \(plantsToEdit.count) plants.")
            if let navController = navigationController {
                for vc in navController.viewControllers {
                    if vc is PlantDetailViewController_New {
                        navController.popToViewController(vc, animated: true)
                        return
                    }
                }
                navController.popToRootViewController(animated: true)
            }
            return
        }
        
        // ── NORMAL ADD MODE ──
        let plantCountToAdd = session.plantCount ?? 1
        
        guard let cachedPlant = PlantCatalogueCache.shared.plants.first(where: {
            $0.plantId == session.plantId
        }), let plantMongoId = cachedPlant.mongoId else {
            print("❌ Plant not found in cache or missing mongoId")
            return
        }
        
        // ✅ Get plant name from cache
        let plantName = cachedPlant.plantName
        print("✅ Found plant: \(plantName), mongoId: \(plantMongoId)")
        
        uploadImageIfNeeded(session.imageData) { [weak self] imageUrl in
            guard let self = self else { return }
            
            print("🖼️ Image URL to save: \(imageUrl ?? "nil")")
            
            NetworkManager.shared.addSite(name: siteName, icon: siteIcon) { siteMongoId in
                guard let siteMongoId = siteMongoId else {
                    print("❌ Failed to create/get site")
                    return
                }
                
                print("✅ Site mongoId: \(siteMongoId)")
                
                if !self.siteStore.sites.contains(where: {
                    $0.name.lowercased() == siteName.lowercased()
                }) {
                    self.siteStore.addSite(name: siteName, icon: siteIcon)
                }
                self.siteStore.addPlants(to: siteName, count: plantCountToAdd)
                
                guard let savedSite = self.siteStore.sites.first(where: {
                    $0.name == siteName
                }) else { return }
                
                for index in 1...plantCountToAdd {
                    let userPlant = UserPlant(
                        id: UUID(),
                        plantId: plantMongoId,
                        siteName: siteName,
                        siteID: savedSite.id,
                        imageData: self.session.imageData,
                        lightRequirement: self.session.plantLight,
                        watering: self.session.wateringAnswer,
                        repotting: self.session.repottingAnswer,
                        quantity: 1,
                        isAddedToGarden: true,
                        createdAt: Date(),
                        lastWatered: self.session.lastWateredDate,
                        lastPruned: self.session.lastPrunedDate,
                        lastFertilized: self.session.lastFertilizedDate,
                        lastRepotted: self.session.lastRepottedDate
                    )
                    
                    PlantStore.shared.addPlant(userPlant)
                    print("✅ Plant \(index)/\(plantCountToAdd) saved locally")
                    
                    NetworkManager.shared.addUserPlant(
                        plantId:          plantMongoId,
                        plantName:        plantName,          // ✅ pass plant name
                        siteId:           siteMongoId,
                        siteName:         siteName,
                        imageData:        imageUrl,
                        lightRequirement: self.session.plantLight,
                        watering:         self.session.wateringAnswer,
                        repotting:        self.session.repottingAnswer,
                        quantity:         1,
                        lastWatered:      self.session.lastWateredDate,
                        lastRepotted:     self.session.lastRepottedDate
                    ) { mongoId in
                        if let mongoId = mongoId {
                            print("✅ Plant \(index) synced to MongoDB: \(mongoId)")
                        } else {
                            print("❌ Failed to sync plant \(index)")
                        }
                    }
                }
                
                // ✅ After the loop finishes saving all plants
                print("✅ All \(plantCountToAdd) plants saved for: \(self.session.plantId)")

                // ✅ Refresh from MongoDB so local store is up to date
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.loadAppData()
                }

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showPlantAddedSuccess", sender: self)
                }
            }
        }
    }
}
