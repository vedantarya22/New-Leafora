import UIKit
import PhotosUI

class NewPostViewController: UIViewController, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let placeholderText = "Write a caption..."
    let maxCaptionLength = 20
    var charCountLabel: UILabel!
    
    var currentUser: User?
    var onPostSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImagePlaceholder()
        setupTapGesture()
        
        captionTextView.keyboardDismissMode = .onDrag
        setupCaptionTextView()
    
        // fetches user
        UserSession.shared.fetchCurrentUser { [weak self] user in
            self?.currentUser = user
        }
    }
    
    func setupImagePlaceholder() {
        selectedImageView.layer.cornerRadius = 16
        selectedImageView.backgroundColor = .systemGray6

        
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: .light)
        selectedImageView.image = UIImage(systemName: "camera.fill", withConfiguration: config)
        selectedImageView.tintColor = .systemGray3
    }
    
    // MARK: - Caption Logic (Making it look like a Field)
    func setupCaptionTextView() {
        captionTextView.delegate = self
        captionTextView.text = placeholderText
        captionTextView.textColor = .lightGray
        captionTextView.font = UIFont.systemFont(ofSize: 16)
        
        // Remove the default padding so it aligns with the image
        captionTextView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        
        // Character counter label
        charCountLabel = UILabel()
        charCountLabel.text = "0/\(maxCaptionLength)"
        charCountLabel.font = UIFont.systemFont(ofSize: 12)
        charCountLabel.textColor = .systemGray
        charCountLabel.textAlignment = .right
        charCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(charCountLabel)
        
        NSLayoutConstraint.activate([
            charCountLabel.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 4),
            charCountLabel.trailingAnchor.constraint(equalTo: captionTextView.trailingAnchor, constant: -5)
        ])
    }
    
    // TextView Delegate: Clears placeholder when you start typing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = nil
            textView.textColor = .label // Black (or White in Dark Mode)
        }
    }
    
    // puts placeholder back if you type nothing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
            updateCharCount(0)
        }
    }
    
    // Enforce character limit
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't limit if it's still the placeholder
        if textView.textColor == .lightGray { return true }
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return updatedText.count <= maxCaptionLength
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.textColor == .lightGray ? 0 : (textView.text?.count ?? 0)
        updateCharCount(count)
    }
    
    private func updateCharCount(_ count: Int) {
        charCountLabel.text = "\(count)/\(maxCaptionLength)"
        charCountLabel.textColor = count >= maxCaptionLength ? .systemRed : .systemGray
    }
    
    //recognizes tap gesture on uiview to select pic
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        selectedImageView.addGestureRecognizer(tapGesture)
        selectedImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    
    @objc func imageTapped() {
        let alert = UIAlertController(title: "Add Photo", message: "Choose a source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in self.openCamera() }))
        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { _ in self.openGallery() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        //Checks if image is set and caption is not the placeholder
        if selectedImageView.contentMode == .center {
            showAlert(message: "Please choose a picture first!")
            return}
        if captionTextView.text == placeholderText || captionTextView.text.isEmpty { showAlert(message: "Please write a caption!")
            return}
        
        guard let image = selectedImageView.image, let _ = currentUser else { return }
        
        shareButton.isEnabled = false
        
        PostRepository.shared.addNewPost(caption: captionTextView.text, image: image) { success in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onPostSuccess?()
                self.dismiss(animated: true)
            }
        }
    }
    
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Missing Info",message:message,preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera; picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    func openGallery() {
        var config = PHPickerConfiguration(); config.filter = .images; config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config); picker.delegate = self
        present(picker, animated: true)
    }
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let result = results.first {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    DispatchQueue.main.async { if let img = image as? UIImage { self?.updateImageView(with: img) } }
                }
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage { updateImageView(with: img) }
    }
    func updateImageView(with image: UIImage) {
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.image = image
    }
}
