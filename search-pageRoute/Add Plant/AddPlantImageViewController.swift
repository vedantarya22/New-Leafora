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
        
        setupImagePlaceholder()
        
        //        saveButton.tintColor = UIColor.
        //saveButton.backgroundColor = .green
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
        //        performSegue(withIdentifier: "showPlantAddedSuccess", sender: nil)
        guard
            let siteName = session.siteName,
            let siteIcon = session.siteIcon
        else {
            print("Missing site info in session")
            return
        }
        
        //        saveButton.backgroundColor = .red
        
        //        let siteColor = UIColor.systemGreen  // can change later
        let plantCountToAdd = session.plantCount ?? 1
        
        print("Adding \(plantCountToAdd) plants to: \(siteName)")
        
        // If site does NOT exist → create it
        if !siteStore.sites.contains(where: {
            $0.name.lowercased() == siteName.lowercased()
        }) {
            
            // Create new site
            siteStore.addSite(
                name: siteName,
                //                color: siteColor,
                icon: siteIcon
            )
            
            print("New site saved:", siteName)
            
        } else {
            print(" Site already exists, not creating again")
            
        }
        
        siteStore.addPlants(to: siteName, count: plantCountToAdd)
        
        //  Get the saved site (to get its ID)
        guard
            let savedSite = siteStore.sites.first(where: { $0.name == siteName }
            )
        else { return }
        
        let lastWaterDate = session.lastWateredDate
        let lastRepotDate = session.lastRepottedDate

        let userPlant = UserPlant(
            id: UUID(),
            plantId: session.plantId,
            siteName: siteName,
            siteID: savedSite.id,
            imageData: session.imageData,
            lightRequirement: session.plantLight,
            watering: session.wateringAnswer,
            repotting: session.repottingAnswer,
            quantity: plantCountToAdd,
            isAddedToGarden: true,

//            // smart task states
//            wateringDone: lastWaterDate != nil,
//            pruningDone: false,
//            fertilizingDone: false,
//            repottingDone: lastRepotDate != nil,

            createdAt: Date(),

            // smart timestamps
            lastWatered: lastWaterDate,
            lastPruned: nil,
            lastFertilized: nil,
            lastRepotted: lastRepotDate
        )

        
        PlantStore.shared.addPlant(userPlant)
        print(" Plant saved:", session.plantId)
        
    }
}
