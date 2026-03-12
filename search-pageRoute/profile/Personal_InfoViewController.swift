import UIKit
import PhotosUI

class Personal_InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPickerViewControllerDelegate {

   @IBOutlet weak var Imageview: UIImageView!
   @IBOutlet weak var Cellview: UIView!
   @IBOutlet weak var Table: UITableView!

    private var originalUser: User?
    private var draftUser: User?
    private var isEditingProfile = false
    private var imageTapGesture: UITapGestureRecognizer?
    private var cameraBadge: UIImageView?
    private let gradientLayer = CAGradientLayer.backgroundGreen()
    
    // Dynamic sections based on draftUser
    private var sections: [PersonalInfoSection] {
        guard let user = draftUser else { return [] }
        return [
            PersonalInfoSection(title: "Basic Info", items: [
                PersonalInfoItem(title: "Full Name", value: user.name, showsChevron: false),
                PersonalInfoItem(title: "Username", value: user.username, showsChevron: false),
                PersonalInfoItem(title: "Email", value: user.email ?? "", showsChevron: false),
                PersonalInfoItem(title: "Phone Number", value: user.phoneNumber ?? "", showsChevron: false),
                PersonalInfoItem(title: "Date Of Birth", value: user.dateOfBirth ?? "", showsChevron: false)
            ])
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Personal Info"
        
        // ✅ App theme
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen
        
        // Initialize state
        if let currentUser = UserSession.shared.currentUser {
            originalUser = currentUser
            draftUser = currentUser.copy()
        }

        setupTableView()
        setupHeader()
        setupEditButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    
    // Updates draftUser from current cell values
    private func updateDraftState() {
        guard let draftUser = draftUser else { return }
        
        for cell in Table.visibleCells {
            guard let indexPath = Table.indexPath(for: cell),
                  let cell = cell as? PersonalInfoTableViewCell,
                  let text = cell.valueTextField.text else { continue }

            let itemTitle = sections[indexPath.section].items[indexPath.row].title
            
            switch itemTitle {
            case "Full Name": draftUser.name = text
            case "Username": draftUser.username = text
            case "Email": draftUser.email = text
            case "Phone Number": draftUser.phoneNumber = text
            case "Date Of Birth": draftUser.dateOfBirth = text
            default: break
            }
        }
    }
    
    private func saveProfileData() {
        updateDraftState()
        
        if let finalUser = draftUser {
            // Commit to session
            UserSession.shared.updateUser(finalUser)
            // Update original user to match the new saved state
            originalUser = finalUser.copy()
        }
    }


    @objc private func editButtonTapped() {
        if isEditingProfile {
            // Saving changes
            view.endEditing(true)
            saveProfileData()
        } else {
            // Starting edit: Ensure draft matches original
            draftUser = originalUser?.copy()
        }

        isEditingProfile.toggle()

        if isEditingProfile {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "checkmark"),
                style: .plain,
                target: self,
                action: #selector(editButtonTapped)
            )
        } else {
            // Cancelled or Saved: Revert to original text (if cancelled) or show saved (if saved)
            // Actually, if we just saved, originalUser is updated.
            // If we cancelled (handled by back or logic?), we should revert.
            // But this specific toggle action implies "Done" (Save).
            // A "Cancel" button would be separate. For now, "Edit -> Done" workflow.
            setupEditButton()
        }

        Table.reloadData()
        setupHeader()
    }

    private func setupTableView() {
        Table.delegate = self
        Table.dataSource = self
        Table.tableFooterView = UIView()
        Table.tableHeaderView = Cellview
        Table.backgroundColor = .clear
        Cellview.backgroundColor = .clear
    }

    private func setupHeader() {
        guard let user = originalUser else { return }
        Imageview.configureImage(with: user.profileImageString)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds = true
        Imageview.contentMode = .scaleAspectFill
        
        // Camera badge (hidden by default, shown in edit mode)
        if cameraBadge == nil {
            let badge = UIImageView(image: UIImage(systemName: "camera.circle.fill"))
            badge.tintColor = .systemGray
            badge.backgroundColor = .systemBackground
            badge.layer.cornerRadius = 15
            badge.clipsToBounds = true
            badge.translatesAutoresizingMaskIntoConstraints = false
            Imageview.superview?.addSubview(badge)
            NSLayoutConstraint.activate([
                badge.widthAnchor.constraint(equalToConstant: 30),
                badge.heightAnchor.constraint(equalToConstant: 30),
                badge.trailingAnchor.constraint(equalTo: Imageview.trailingAnchor, constant: 2),
                badge.bottomAnchor.constraint(equalTo: Imageview.bottomAnchor, constant: 2)
            ])
            cameraBadge = badge
        }
        cameraBadge?.isHidden = !isEditingProfile
        
        // Tap gesture for image (only active during edit)
        if imageTapGesture == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
            Imageview.addGestureRecognizer(tap)
            imageTapGesture = tap
        }
        Imageview.isUserInteractionEnabled = isEditingProfile
    }
    
    @objc private func profileImageTapped() {
        guard isEditingProfile else { return }
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let selectedImage = image as? UIImage else { return }
            
            // Save to Documents
            let imageID = "profile_\(self.draftUser?.id ?? UUID().uuidString)"
            let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = docsDir.appendingPathComponent(imageID)
            
            if let data = selectedImage.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
            }
            
            DispatchQueue.main.async {
                // Update draft
                self.draftUser?.profileImageString = imageID
                
                // Update header image
                self.Imageview.image = selectedImage
                self.Imageview.contentMode = .scaleAspectFill
                self.Imageview.clipsToBounds = true
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell",
            for: indexPath
        ) as! PersonalInfoTableViewCell

        let item = sections[indexPath.section].items[indexPath.row]

        cell.configure(
            title: item.title,
            value: item.value,
            isEditing: isEditingProfile, showsChevron: item.showsChevron
        )

        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
