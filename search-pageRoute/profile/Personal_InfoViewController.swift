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

    // Dynamic sections built from draftUser
    private var sections: [PersonalInfoSection] {
        guard let user = draftUser else { return [] }
        return [
            PersonalInfoSection(title: "Basic Info", items: [
                PersonalInfoItem(title: "Full Name",    value: user.name,            showsChevron: false),
                PersonalInfoItem(title: "Username",     value: user.username,        showsChevron: false),
                PersonalInfoItem(title: "Email",        value: user.email ?? "",     showsChevron: false),
                PersonalInfoItem(title: "Phone Number", value: user.phoneNumber ?? "", showsChevron: false),
                PersonalInfoItem(title: "Date Of Birth",value: user.dateOfBirth ?? "", showsChevron: false)
            ])
        ]
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Personal Info"

        view.layer.insertSublayer(gradientLayer, at: 0)
        navigationController?.navigationBar.tintColor = .brandGreen

        // ✅ Use cachedCurrentUser — populated by fetchCurrentUser() after login
        if let currentUser = UserSession.shared.currentUser {
            originalUser = currentUser
            draftUser    = currentUser.copy()
        } else {
            // Fallback: fetch from backend if cache is cold
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

    // MARK: - Edit Button
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

    // MARK: - Save
    private func updateDraftState() {
        guard let draftUser = draftUser else { return }
        for cell in Table.visibleCells {
            guard let indexPath = Table.indexPath(for: cell),
                  let cell = cell as? PersonalInfoTableViewCell,
                  let text = cell.valueTextField.text else { continue }
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

    private func saveProfileData() {
        updateDraftState()
        guard let finalUser = draftUser else { return }

        // ✅ updateUser no longer exists on UserSession — update the cache directly
        UserSession.shared.cachedCurrentUser = finalUser
        originalUser = finalUser.copy()

        // TODO: when you add PATCH /api/users/:id to the backend, call it here:
        // NetworkManager.shared.updateUserProfile(finalUser) { success in ... }
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
        // ✅ profileImageString lives on the User object — no UserSession helper needed
        let imageString = originalUser?.profileImageString ?? "person.circle.fill"
        Imageview.configureImage(with: imageString)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds  = true
        Imageview.contentMode    = .scaleAspectFill

        if cameraBadge == nil {
            let badge = UIImageView(image: UIImage(systemName: "camera.circle.fill"))
            badge.tintColor       = .systemGray
            badge.backgroundColor = .systemBackground
            badge.layer.cornerRadius = 15
            badge.clipsToBounds   = true
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
        var config = PHPickerConfiguration()
        config.filter         = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self = self, let selectedImage = image as? UIImage else { return }

            // Upload to Cloudinary so the URL is persistent across devices
            guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else { return }

            NetworkManager.shared.uploadImageToCloudinary(imageData) { [weak self] imageUrl in
                guard let self = self, let imageUrl = imageUrl else {
                    print("❌ Profile image upload failed")
                    return
                }
                // Store the Cloudinary URL on the draft
                self.draftUser?.profileImageString = imageUrl
                self.Imageview.image         = selectedImage
                self.Imageview.contentMode   = .scaleAspectFill
                self.Imageview.clipsToBounds = true
            }
        }
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                  for: indexPath) as! PersonalInfoTableViewCell
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(title: item.title, value: item.value,
                       isEditing: isEditingProfile, showsChevron: item.showsChevron)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
