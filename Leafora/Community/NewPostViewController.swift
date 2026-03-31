//
//  NewPostViewController.swift
//  Leafora
//

import UIKit
import PhotosUI

class NewPostViewController: UIViewController,
                              PHPickerViewControllerDelegate,
                              UIImagePickerControllerDelegate,
                              UINavigationControllerDelegate,
                              UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!

    // MARK: - Config
    let placeholderText  = "Write a caption..."
    let maxCaptionLength = 100
    var charCountLabel: UILabel!

    // recals to refresh the feed for new post
    var onPostSuccess: (() -> Void)?

    // MARK: - Plantation Drive Properties
    let postTypeSegment = UISegmentedControl(items: ["Regular Post", "Plantation Drive"])
    let plantationContainer = UIStackView()
    let datePicker = UIDatePicker()
    let addLocationButton = UIButton(type: .system)
    let locationLabel = UILabel()
    
    var selectedLocationName: String?
    var selectedLocationLat: Double?
    var selectedLocationLng: Double?

    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen

        setupImagePlaceholder()
        setupTapGesture()
        setupCaptionTextView()
        captionTextView.keyboardDismissMode = .onDrag
        
        setupPlantationUI()

        //backend fetches curr user from jwt/isLoggedin
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Image Placeholder
    func setupImagePlaceholder() {
        selectedImageView.layer.cornerRadius = 16
        selectedImageView.backgroundColor    = .white
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        selectedImageView.image    = UIImage(systemName: "camera.fill", withConfiguration: config)
        selectedImageView.tintColor = .systemGray3
    }

    // MARK: - Caption
    func setupCaptionTextView() {
        captionTextView.delegate   = self
        captionTextView.text       = placeholderText
        captionTextView.textColor  = .lightGray
        captionTextView.font       = .systemFont(ofSize: 16)
        captionTextView.backgroundColor = .clear
        captionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)

        charCountLabel = UILabel()
        charCountLabel.text          = "0/\(maxCaptionLength)"
        charCountLabel.font          = .systemFont(ofSize: 12)
        charCountLabel.textColor     = .systemGray
        charCountLabel.textAlignment = .right
        charCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(charCountLabel)

        NSLayoutConstraint.activate([
            charCountLabel.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 4),
            charCountLabel.trailingAnchor.constraint(equalTo: captionTextView.trailingAnchor, constant: -5)
        ])
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text      = nil
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text      = placeholderText
            textView.textColor = .lightGray
            updateCharCount(0)
        }
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if textView.textColor == .lightGray { return true }
        guard let str = textView.text,
              let r   = Range(range, in: str) else { return false }
        return str.replacingCharacters(in: r, with: text).count <= maxCaptionLength
    }

    func textViewDidChange(_ textView: UITextView) {
        let count = textView.textColor == .lightGray ? 0 : (textView.text?.count ?? 0)
        updateCharCount(count)
    }

    private func updateCharCount(_ count: Int) {
        charCountLabel.text      = "\(count)/\(maxCaptionLength)"
        charCountLabel.textColor = count >= maxCaptionLength ? .systemRed : .systemGray
    }

    // MARK: - Plantation Drive UI
    func setupPlantationUI() {
        // Segmented Control
        postTypeSegment.selectedSegmentIndex = 0
        postTypeSegment.addTarget(self, action: #selector(postTypeChanged), for: .valueChanged)
        postTypeSegment.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postTypeSegment)
        
        // Container
        plantationContainer.axis = .vertical
        plantationContainer.spacing = 15
        plantationContainer.isHidden = true
        plantationContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plantationContainer)
        
        // Date Picker Stack
        let dateStack = UIStackView()
        dateStack.axis = .horizontal
        dateStack.spacing = 10
        let dateLabel = UILabel()
        dateLabel.text = "Event Date:"
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) { datePicker.preferredDatePickerStyle = .compact }
        datePicker.date = Date().addingTimeInterval(7 * 24 * 60 * 60) // 1 week from now
        dateStack.addArrangedSubview(dateLabel)
        dateStack.addArrangedSubview(datePicker)
        plantationContainer.addArrangedSubview(dateStack)
        
        // Location Button
        addLocationButton.setTitle("📍 Add Location", for: .normal)
        addLocationButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        addLocationButton.tintColor = .brandGreen
        addLocationButton.addTarget(self, action: #selector(addLocationTapped), for: .touchUpInside)
        plantationContainer.addArrangedSubview(addLocationButton)
        
        // Location Label
        locationLabel.text = "No location selected"
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0
        locationLabel.textAlignment = .center
        plantationContainer.addArrangedSubview(locationLabel)
        
        NSLayoutConstraint.activate([
            postTypeSegment.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 30),
            postTypeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            postTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            postTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            plantationContainer.topAnchor.constraint(equalTo: postTypeSegment.bottomAnchor, constant: 20),
            plantationContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            plantationContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func postTypeChanged() {
        UIView.animate(withDuration: 0.3) {
            self.plantationContainer.isHidden = self.postTypeSegment.selectedSegmentIndex == 0
        }
    }
    
    @objc func addLocationTapped() {
        let picker = LocationPickerViewController()
        picker.onLocationSelected = { [weak self] name, lat, lng in
            self?.selectedLocationName = name
            self?.selectedLocationLat = lat
            self?.selectedLocationLng = lng
            self?.locationLabel.text = "📍 \(name)"
            self?.addLocationButton.setTitle("📍 Edit Location", for: .normal)
        }
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    // MARK: - Tap to Pick Image
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        selectedImageView.addGestureRecognizer(tap)
        selectedImageView.isUserInteractionEnabled = true
    }

    @objc func imageTapped() {
        let alert = UIAlertController(title: "Add Photo",
                                      message: "Choose a source",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo",           style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Choose from Gallery",  style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel",               style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Share
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        // checking if user is logged in with jwt
        guard UserSession.shared.isLoggedIn else {
            showAlert(message: "Please log in to share a post.")
            return
        }

        // choosing pic
        guard selectedImageView.contentMode != .center else {
            showAlert(message: "Please choose a picture first!")
            return
        }

        // writing caption
        let caption = captionTextView.text ?? ""
        guard caption != placeholderText, !caption.isEmpty else {
            showAlert(message: "Please write a caption!")
            return
        }

        guard let image = selectedImageView.image else { return }

        let isPlantation = postTypeSegment.selectedSegmentIndex == 1
        if isPlantation && selectedLocationLat == nil {
            showAlert(message: "Please add a location for the Plantation Drive.")
            return
        }

        // preventing double tap on share button
        shareButton.isEnabled = false

        let dateStr = isPlantation ? ISO8601DateFormatter().string(from: datePicker.date) : nil

        // uploading post and sharing to feed
        PostRepository.shared.addNewPost(caption: caption, image: image, isPlantationDrive: isPlantation, plantationDate: dateStr, locationName: selectedLocationName, locationLat: selectedLocationLat, locationLng: selectedLocationLng) { [weak self] success in
            guard let self = self else { return }

            self.shareButton.isEnabled = true   // re-enable share button

            if success {
                self.onPostSuccess?()           // reloading feed
                self.dismiss(animated: true)
            } else {
                self.showAlert(message: "Failed to share post. Please try again.")
            }
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    // MARK: - Camera / Gallery
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate     = self
        picker.sourceType   = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func openGallery() {
        var config = PHPickerConfiguration()
        config.filter         = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first,
              result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let img = image as? UIImage { self?.updateImageView(with: img) }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            updateImageView(with: img)
        }
    }

    func updateImageView(with image: UIImage) {
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.image       = image
    }
}
