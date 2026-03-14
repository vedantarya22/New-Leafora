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

    // Callback — CommunityViewController sets this to reload the feed
    var onPostSuccess: (() -> Void)?

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

        // ── No longer needs to fetch currentUser ──────────────────────────
        // The backend derives the author from the JWT — we just need isLoggedIn.
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
        // 1. Must be logged in (JWT present)
        guard UserSession.shared.isLoggedIn else {
            showAlert(message: "Please log in to share a post.")
            return
        }

        // 2. Must have picked an image (contentMode changes from .center after selection)
        guard selectedImageView.contentMode != .center else {
            showAlert(message: "Please choose a picture first!")
            return
        }

        // 3. Must have a non-placeholder caption
        let caption = captionTextView.text ?? ""
        guard caption != placeholderText, !caption.isEmpty else {
            showAlert(message: "Please write a caption!")
            return
        }

        guard let image = selectedImageView.image else { return }

        // 4. Disable button to prevent double-tap
        shareButton.isEnabled = false

        // 5. Upload → create post → notify feed
        PostRepository.shared.addNewPost(caption: caption, image: image) { [weak self] success in
            guard let self = self else { return }

            self.shareButton.isEnabled = true   // re-enable in case of failure

            if success {
                self.onPostSuccess?()           // reload feed in CommunityVC
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
