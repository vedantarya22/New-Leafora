//
//  CameraOptionViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 08/12/25.
//

import Foundation
import PhotosUI
import UIKit

class AddPlantImageViewController: UIViewController,
                                  UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                  UITextViewDelegate, PHPickerViewControllerDelegate
{
    
    var selectedPlant: Plant?
    
    var session: PlantQuestionSession!
    let siteStore = SiteStore.shared
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupImageTapGesture()
        
        // ✏️ In edit mode, show existing image if available
        if session.isEditMode, let existingData = session.imageData, let existingImage = UIImage(data: existingData) {
            plantImageView.layer.cornerRadius = 16
            plantImageView.image = existingImage
            plantImageView.contentMode = .scaleAspectFill
            plantImageView.clipsToBounds = true
        } else {
            setupImagePlaceholder()
        }
    }
    
    // MARK: - Add Tap Gesture to ImageView
    func setupImageTapGesture() {
        plantImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(showImagePickerOptions)
        )
        plantImageView.addGestureRecognizer(tap)
    }
    
    // MARK: - Image view styl
    
    func setupImagePlaceholder() {
        plantImageView.layer.cornerRadius = 16
        plantImageView.backgroundColor = .systemGray6
        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        plantImageView.image = UIImage(
            systemName: "camera.fill",
            withConfiguration: config
        )
        plantImageView.tintColor = .systemGray3
    }
    
    // MARK: - Show Action Sheet
    @objc func showImagePickerOptions() {
        let alert = UIAlertController(
            title: "Add a Photo",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Take Photo",
                style: .default,
                handler: { _ in
                    self.openCamera()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Choose from Gallery",
                style: .default,
                handler: { _ in
                    self.openGallery()
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        present(alert, animated: true)
    }
    
    // MARK: - Open Camera
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
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
    
    // MARK: - Gallery Image Selected (PHPicker)
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self)
        else { return }
        
        provider.loadObject(ofClass: UIImage.self) { image, error in
            DispatchQueue.main.async {
                if let img = image as? UIImage {
                    self.updateSelectedImage(img)
                }
            }
        }
    }
    
    // MARK: - Update UI + Save to answers
    func updateSelectedImage(_ image: UIImage) {
        plantImageView.image = image  //  Show preview
        session.imageData = image.jpegData(compressionQuality: 0.8)  // Save image
        print("Image saved in session")
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard
            let siteName = session.siteName,
            let siteIcon = session.siteIcon
        else {
            print("Missing site info in session")
            return
        }

        // ✏️ EDIT MODE: Batch Edit / Shift
        if session.isEditMode,
           let editingBatchSiteID = session.editingBatchSiteID,
           let editingBatchCreatedAt = session.editingBatchCreatedAt,
           let targetQuantity = session.plantCount {
            
            // 1. Find the original batch
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateKey = formatter.string(from: editingBatchCreatedAt)
            
            let allPlantsInSite = PlantStore.shared.plants(for: editingBatchSiteID)
            var originalBatch = allPlantsInSite.filter {
                $0.plantId == session.plantId &&
                formatter.string(from: $0.createdAt) == dateKey
            }
            
            // Safety check
            if originalBatch.isEmpty {
                print("❌ Could not find original batch to edit.")
                return
            }
            
            // 2. Select exactly `targetQuantity` plants to apply the edit to.
            let plantsToEdit = Array(originalBatch.prefix(targetQuantity))
            
            // 3. Identify any excess plants that need to be removed (if the user reduced the quantity)
            let plantsToRemove = Array(originalBatch.dropFirst(targetQuantity))
            
            // 4. Apply edits to the selected plants (or move them to a new site)
            for mutPlant in plantsToEdit {
                var updatedPlant = mutPlant
                
                // Update the site if changed
                if updatedPlant.siteName != siteName {
                    if !siteStore.sites.contains(where: { $0.name.lowercased() == siteName.lowercased() }) {
                        siteStore.addSite(name: siteName, icon: siteIcon)
                    }
                    if let newSite = siteStore.sites.first(where: { $0.name == siteName }) {
                        updatedPlant.siteName = siteName
                        updatedPlant.siteID = newSite.id
                    }
                }

                // Update fields from session
                updatedPlant.imageData = session.imageData
                updatedPlant.lightRequirement = session.plantLight
                updatedPlant.watering = session.wateringAnswer
                updatedPlant.repotting = session.repottingAnswer
                updatedPlant.lastWatered = session.lastWateredDate
                updatedPlant.lastRepotted = session.lastRepottedDate
                updatedPlant.lastPruned = session.lastPrunedDate
                updatedPlant.lastFertilized = session.lastFertilizedDate

                PlantStore.shared.updatePlant(updatedPlant)
            }
            
            // 5. Remove the excess plants if quantity was reduced
            for plantToRemove in plantsToRemove {
                PlantStore.shared.removePlant(by: plantToRemove.id)
            }
            
            print("✅ Batch edit complete. Edited \(plantsToEdit.count), Removed \(plantsToRemove.count) excess plants.")

            // Pop back to the plant detail screen
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

        // ── NORMAL ADD MODE (unchanged) ──
        let plantCountToAdd = session.plantCount ?? 1
        
        print("Adding \(plantCountToAdd) plants to: \(siteName)")
        
        // If site does NOT exist → create it
        if !siteStore.sites.contains(where: {
            $0.name.lowercased() == siteName.lowercased()
        }) {
            siteStore.addSite(
                name: siteName,
                icon: siteIcon
            )
            print("New site saved:", siteName)
        } else {
            print(" Site already exists, not creating again")
        }
        
        siteStore.addPlants(to: siteName, count: plantCountToAdd)
        
        guard
            let savedSite = siteStore.sites.first(where: { $0.name == siteName }
            )
        else { return }
        
        let lastWaterDate = session.lastWateredDate
        let lastRepotDate = session.lastRepottedDate
        let lastPruneDate = session.lastPrunedDate
        let lastFertDate = session.lastFertilizedDate

        for index in 1...plantCountToAdd {
               let userPlant = UserPlant(
                   id: UUID(),
                   plantId: session.plantId,
                   siteName: siteName,
                   siteID: savedSite.id,
                   imageData: session.imageData,
                   lightRequirement: session.plantLight,
                   watering: session.wateringAnswer,
                   repotting: session.repottingAnswer,
                   quantity: 1,
                   isAddedToGarden: true,
                   createdAt: Date(),
                   lastWatered: lastWaterDate,
                   lastPruned: lastPruneDate,
                   lastFertilized: lastFertDate,
                   lastRepotted: lastRepotDate
               )
               
               PlantStore.shared.addPlant(userPlant)
               print("✅ Plant \(index)/\(plantCountToAdd) saved with ID:", userPlant.id)
           }

        print("✅ All \(plantCountToAdd) plants saved for:", session.plantId)
        performSegue(withIdentifier: "showPlantAddedSuccess", sender: self)
    }
}
