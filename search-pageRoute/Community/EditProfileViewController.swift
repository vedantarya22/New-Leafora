//import UIKit
//import PhotosUI
//
//class EditProfileViewController: UIViewController,
//                                  UIPickerViewDelegate,
//                                  UIPickerViewDataSource,
//                                  PHPickerViewControllerDelegate {
//
//    // MARK: - Outlets
//    @IBOutlet weak var profileImageView: UIImageView!
//    @IBOutlet weak var cameraBadgeView: UIView!
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var personalityTextField: UITextField!
//    @IBOutlet weak var saveButton: UIButton!
//
//    // MARK: - Properties
//    var user: User?
//    private var selectedImage: UIImage?   // holds the newly picked image before upload
//
//    let personalities = [
//        "Indoor Gardener 🏠",
//        "Succulent Master 🌵",
//        "Outdoor Explorer 🌲",
//        "Vegetable Grower 🥕",
//        "Newbie Planter 🌱",
//        "Floral Enthusiast 🌸"
//    ]
//    var personalityPicker = UIPickerView()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        populateData()
//        setupPicker()
//    }
//
//    // MARK: - Setup UI
//    func setupUI() {
//        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
//        profileImageView.contentMode        = .scaleAspectFill
//        profileImageView.clipsToBounds      = true
//
//        cameraBadgeView.layer.cornerRadius = 20
//        cameraBadgeView.layer.borderColor  = UIColor.systemBackground.cgColor
//
//        styleTextField(nameTextField)
//        styleTextField(usernameTextField)
//        styleTextField(personalityTextField)
//
//        saveButton.layer.cornerRadius = 20
//        saveButton.clipsToBounds      = true
//
//        // ✅ Tap gesture on profile image to change it
//        let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        profileImageView.isUserInteractionEnabled = true
//        profileImageView.addGestureRecognizer(tap)
//
//        // Also tappable via the camera badge
//        let badgeTap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        cameraBadgeView.isUserInteractionEnabled = true
//        cameraBadgeView.addGestureRecognizer(badgeTap)
//    }
//
//    func styleTextField(_ textField: UITextField) {
//        textField.layer.cornerRadius = 12
//        textField.backgroundColor    = UIColor.systemGray6
//        textField.clipsToBounds      = true
//    }
//
//    func setupPicker() {
//        personalityPicker.delegate   = self
//        personalityPicker.dataSource = self
//        personalityTextField.inputView = personalityPicker
//
//        let toolbar    = UIToolbar()
//        toolbar.sizeToFit()
//        let done  = UIBarButtonItem(title: "Done", style: .done,
//                                    target: self, action: #selector(dismissPicker))
//        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
//                                    target: nil, action: nil)
//        toolbar.setItems([space, done], animated: false)
//        personalityTextField.inputAccessoryView = toolbar
//    }
//
//    @objc func dismissPicker() { view.endEditing(true) }
//
//    func populateData() {
//        guard let user = user else { return }
//        profileImageView.configureImage(with: user.profileImageString ?? "person.circle.fill")
//        nameTextField.text     = user.name
//        usernameTextField.text = user.username.replacingOccurrences(of: "@", with: "")
//    }
//
//    // MARK: - Profile Image Tap
//    @objc func profileImageTapped() {
//        let alert = UIAlertController(title: "Change Photo",
//                                      message: nil,
//                                      preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
//            self.openCamera()
//        })
//        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
//            self.openGallery()
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//
//    private func openCamera() {
//        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
//        let picker        = UIImagePickerController()
//        picker.delegate   = self
//        picker.sourceType = .camera
//        picker.allowsEditing = true
//        present(picker, animated: true)
//    }
//
//    private func openGallery() {
//        var config            = PHPickerConfiguration()
//        config.filter         = .images
//        config.selectionLimit = 1
//        let picker            = PHPickerViewController(configuration: config)
//        picker.delegate       = self
//        present(picker, animated: true)
//    }
//
//    // MARK: - PHPickerViewControllerDelegate
//    func picker(_ picker: PHPickerViewController,
//                didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        guard let result = results.first,
//              result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
//
//        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//            DispatchQueue.main.async {
//                guard let img = image as? UIImage else { return }
//                self?.selectedImage = img
//                self?.profileImageView.image       = img
//                self?.profileImageView.contentMode = .scaleAspectFill
//            }
//        }
//    }
//
//    // MARK: - Actions
//    @IBAction func backTapped(_ sender: Any) {
//        dismiss(animated: true)
//    }
//
//    @IBAction func saveTapped(_ sender: Any) {
//        guard let user = user else { return }
//
//        saveButton.isEnabled = false
//        let name     = nameTextField.text?.trimmingCharacters(in: .whitespaces) ?? user.name
//        let username = usernameTextField.text?.trimmingCharacters(in: .whitespaces) ?? user.username
//
//        if let newImage = selectedImage {
//            // ✅ Upload new image to Cloudinary first, then save profile
//            guard let imageData = newImage.jpegData(compressionQuality: 0.8) else { return }
//
//            NetworkManager.shared.uploadImageToCloudinary(imageData) { [weak self] imageUrl in
//                guard let self = self else { return }
//                self.saveProfile(userId: user.id, name: name,
//                                 username: username, profileImageUrl: imageUrl)
//            }
//        } else {
//            // No image change — just update name/username
//            saveProfile(userId: user.id, name: name,
//                        username: username, profileImageUrl: nil)
//        }
//    }
//
//    // MARK: - Save Profile to Backend
//    private func saveProfile(userId: String, name: String,
//                              username: String, profileImageUrl: String?) {
//        NetworkManager.shared.updateUserProfile(
//            userId: userId, name: name,
//            username: username, profileImageString: profileImageUrl
//        ) { [weak self] success in
//            guard let self = self else { return }
//            self.saveButton.isEnabled = true
//
//            if success {
//                // Update local cache
//                if let cached = UserSession.shared.cachedCurrentUser {
//                    cached.name     = name
//                    cached.username = username
//                    if let url = profileImageUrl {
//                        cached.profileImageString = url
//                        // ✅ Refresh feed so post author images update too
//                        PostRepository.shared.updateAuthorImage(userId: userId, newImageUrl: url)
//                    }
//                    UserSession.shared.cachedCurrentUser = cached
//                }
//                self.dismiss(animated: true)
//            } else {
//                let alert = UIAlertController(title: "Error",
//                                              message: "Failed to save profile. Try again.",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
//            }
//        }
//    }
//
//    // MARK: - PickerView
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    numberOfRowsInComponent component: Int) -> Int { personalities.count }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    titleForRow row: Int,
//                    forComponent component: Int) -> String? { personalities[row] }
//
//    func pickerView(_ pickerView: UIPickerView,
//                    didSelectRow row: Int,
//                    inComponent component: Int) {
//        personalityTextField.text = personalities[row]
//    }
//}
//
//// MARK: - UIImagePickerControllerDelegate
//extension EditProfileViewController: UIImagePickerControllerDelegate,
//                                      UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController,
//                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        picker.dismiss(animated: true)
//        if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
//            selectedImage                      = img
//            profileImageView.image             = img
//            profileImageView.contentMode       = .scaleAspectFill
//        }
//    }
//}
