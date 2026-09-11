import UIKit
import PhotosUI

class Personal_InfoViewController: UIViewController,
                                    UITableViewDelegate,
                                    UITableViewDataSource,
                                    PHPickerViewControllerDelegate {

    @IBOutlet weak var Imageview: UIImageView!
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var Table: UITableView!

    private var originalUser: User?
    private var draftUser: User?
    private var isEditingProfile = false
    private var imageTapGesture: UITapGestureRecognizer?
    private var cameraBadge: UIImageView?
    private let gradientLayer = CAGradientLayer.backgroundGreen()

    // sections built from draft user
    private var sections: [PersonalInfoSection] {
        guard let user = draftUser else { return [] }
        return [
            PersonalInfoSection(title: "Basic Info", items: [
                PersonalInfoItem(title: "Full Name",     value: user.name,             showsChevron: false),
                PersonalInfoItem(title: "Username",      value: user.username,         showsChevron: false),
                PersonalInfoItem(title: "Email",         value: user.email ?? "",      showsChevron: false),
                PersonalInfoItem(title: "Phone Number",  value: user.phoneNumber ?? "", showsChevron: false),
                PersonalInfoItem(title: "Date Of Birth", value: user.dateOfBirth ?? "", showsChevron: false)
            ])
        ]
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal Info"
        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen

        if let currentUser = UserSession.shared.currentUser {
            originalUser = currentUser
            draftUser    = currentUser.copy()
        } else {
            UserSession.shared.fetchCurrentUser { [weak self] user in
                guard let user = user else { return }
                self?.originalUser = user
                self?.draftUser    = user.copy()
                self?.Table.reloadData()
                self?.setupHeader()
            }
        }

        setupTableView()
        setupHeader()
        setupEditButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Edit / Save Button
    private func setupEditButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit", style: .plain,
            target: self, action: #selector(editButtonTapped)
        )
    }

    @objc private func editButtonTapped() {
        if isEditingProfile {
            view.endEditing(true)
            saveProfileData()
        } else {
            draftUser = originalUser?.copy()
        }

        isEditingProfile.toggle()

        navigationItem.rightBarButtonItem = isEditingProfile
            ? UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .plain,
                              target: self, action: #selector(editButtonTapped))
            : UIBarButtonItem(title: "Edit", style: .plain,
                              target: self, action: #selector(editButtonTapped))

        Table.reloadData()
        setupHeader()
    }

    // MARK: - Collect Field Values
    private func updateDraftState() {
        guard let draftUser = draftUser else { return }
        for cell in Table.visibleCells {
            guard let indexPath = Table.indexPath(for: cell),
                  let cell      = cell as? PersonalInfoTableViewCell,
                  let text      = cell.valueTextField.text else { continue }
            let itemTitle = sections[indexPath.section].items[indexPath.row].title
            switch itemTitle {
            case "Full Name":    draftUser.name        = text
            case "Username":     draftUser.username    = text
            case "Email":        draftUser.email       = text
            case "Phone Number": draftUser.phoneNumber = text
            case "Date Of Birth":draftUser.dateOfBirth = text
            default: break
            }
        }
    }

    // MARK: - Save Profile
    private func saveProfileData() {
        updateDraftState()
        guard let finalUser = draftUser,
              let userId    = UserSession.shared.mongoId else { return }

        // disable save while request runs
        navigationItem.rightBarButtonItem?.isEnabled = false

        // call profile update route
        NetworkManager.shared.updateUserProfile(
            userId:             userId,
            name:               finalUser.name,
            username:           finalUser.username,
            profileImageString: finalUser.profileImageString
        ) { [weak self] success in
            guard let self = self else { return }

            self.navigationItem.rightBarButtonItem?.isEnabled = true

            if success {
                print("Profile saved to MongoDB")

                // update local cache
                UserSession.shared.cachedCurrentUser = finalUser
                self.originalUser = finalUser.copy()

                // refresh community avatars if image changed
                if let newImage = finalUser.profileImageString {
                    PostRepository.shared.updateAuthorImage(userId: userId, newImageUrl: newImage)
                }

                // refresh header image
                self.setupHeader()

            } else {
                print("Profile save failed")
                let alert = UIAlertController(title: "Error",
                                              message: "Failed to save. Please try again.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    // MARK: - Table Setup
    private func setupTableView() {
        Table.delegate        = self
        Table.dataSource      = self
        Table.tableFooterView = UIView()
        Table.tableHeaderView = Cellview
        Table.backgroundColor = .clear
        Cellview.backgroundColor = .clear
    }

    // MARK: - Header
    private func setupHeader() {
        let imageString = originalUser?.profileImageString ?? "person.circle.fill"
        Imageview.configureImage(with: imageString)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds      = true
        Imageview.contentMode        = .scaleAspectFill

        if cameraBadge == nil {
            let badge = UIImageView(image: UIImage(systemName: "camera.circle.fill"))
            badge.tintColor          = .systemGray
            badge.backgroundColor    = .systemBackground
            badge.layer.cornerRadius = 15
            badge.clipsToBounds      = true
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

        if imageTapGesture == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
            Imageview.addGestureRecognizer(tap)
            imageTapGesture = tap
        }
        Imageview.isUserInteractionEnabled = isEditingProfile
    }

    // MARK: - Profile Image Picker
    @objc private func profileImageTapped() {
        guard isEditingProfile else { return }
        var config            = PHPickerConfiguration()
        config.filter         = .images
        config.selectionLimit = 1
        let picker            = PHPickerViewController(configuration: config)
        picker.delegate       = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self = self,
                  let selectedImage = image as? UIImage,
                  let imageData     = selectedImage.jpegData(compressionQuality: 0.8)
            else { return }

            // upload image right after picking
            NetworkManager.shared.uploadImageToCloudinary(imageData) { [weak self] imageUrl in
                guard let self = self, let imageUrl = imageUrl else {
                    print("Profile image upload failed")
                    return
                }
                print("Profile image uploaded: \(imageUrl)")

                // store URL in draft for next save
                self.draftUser?.profileImageString = imageUrl

                // show selected image right away
                DispatchQueue.main.async {
                    self.Imageview.image       = selectedImage
                    self.Imageview.contentMode = .scaleAspectFill
                }
            }
        }
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                  for: indexPath) as! PersonalInfoTableViewCell
        let item = sections[indexPath.section].items[indexPath.row]
        
        // Email is not editable in production/profile edit
        let canEditItem = (item.title == "Email") ? false : isEditingProfile
        
        cell.configure(title: item.title, value: item.value,
                       isEditing: canEditItem, showsChevron: item.showsChevron)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
