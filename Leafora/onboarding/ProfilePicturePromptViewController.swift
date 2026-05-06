import UIKit
import PhotosUI

class ProfilePicturePromptViewController: UIViewController {

    // MARK: - IBOutlets (connected in onboarding.storyboard)
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!

    // MARK: - Lifecycle
    
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.insertSublayer(gradientLayer, at: 0)
        styleAvatarBorder()
        styleAvatarImageView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Styling
    private func styleAvatarBorder() {
        avatarContainerView.layer.borderColor =
            UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 0.35).cgColor
        
        // Solid botanical green background
        avatarContainerView.backgroundColor = UIColor(red: 0.22, green: 0.49, blue: 0.16, alpha: 1.0)
    }

    private func styleAvatarImageView() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 75
    }

    // MARK: - IBActions
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        presentPhotoPicker()
    }

    @IBAction func skipTapped(_ sender: UIButton) {
        navigateToMainApp()
    }

    // MARK: - Photo Picker
    private func presentPhotoPicker() {
        if #available(iOS 14.0, *) {
            var config = PHPickerConfiguration()
            config.filter        = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            let picker = UIImagePickerController()
            picker.sourceType    = .photoLibrary
            picker.allowsEditing = true
            picker.delegate      = self
            present(picker, animated: true)
        }
    }

    // MARK: - After photo selected
    private func didSelectImage(_ image: UIImage) {
        // Show selected photo in the avatar circle
        avatarImageView.image        = image
        avatarImageView.contentMode  = .scaleAspectFill
        avatarImageView.tintColor    = nil

        // Update button label
        addPhotoButton.setTitle("Change Photo", for: .normal)
        if #available(iOS 15.0, *) {
            addPhotoButton.configuration?.title = "Change Photo"
        }

        // Bounce animation on avatar
        UIView.animate(withDuration: 0.15, animations: {
            self.avatarContainerView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }) { _ in
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.55,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseOut) {
                self.avatarContainerView.transform = .identity
            }
        }

        // Upload to backend
        uploadProfilePicture(image)
    }

    private func uploadProfilePicture(_ image: UIImage) {
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            navigateToMainApp(); return
        }
        // Upload image to Cloudinary, then save URL to user profile
        NetworkManager.shared.uploadImageToCloudinary(jpegData) { [weak self] imageUrl in
            guard let self = self else { return }
            guard let url = imageUrl else {
                // Upload failed — navigate anyway, user can set photo from settings later
                DispatchQueue.main.async { self.navigateToMainApp() }
                return
            }
            // Save the URL to the user's profile
            let userId   = UserSession.shared.currentLoggedInUserID
            let name     = UserSession.shared.cachedCurrentUser?.name     ?? ""
            let username = UserSession.shared.cachedCurrentUser?.username ?? ""
            NetworkManager.shared.updateUserProfile(
                userId: userId,
                name: name,
                username: username,
                profileImageString: url
            ) { _ in
                // Force a refresh of the user session so the new photo is available everywhere in the app
                UserSession.shared.fetchCurrentUser { _ in
                    DispatchQueue.main.async { self.navigateToMainApp() }
                }
            }
        }
    }

    // MARK: - Navigation
    private func navigateToMainApp() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
                .first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        UIView.transition(with: window,
                          duration: 0.45,
                          options: .transitionCrossDissolve,
                          animations: nil)
        sceneDelegate.loadAppData()
    }
}

// MARK: - PHPickerViewControllerDelegate (iOS 14+)
@available(iOS 14.0, *)
extension ProfilePicturePromptViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            if let image = object as? UIImage {
                DispatchQueue.main.async { self?.didSelectImage(image) }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate (iOS < 14 fallback)
extension ProfilePicturePromptViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            didSelectImage(image)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
