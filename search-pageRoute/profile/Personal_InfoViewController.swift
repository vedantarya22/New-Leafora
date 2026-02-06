import UIKit

class Personal_InfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   @IBOutlet weak var Imageview: UIImageView!
   @IBOutlet weak var Cellview: UIView!
   @IBOutlet weak var Table: UITableView!

    private var originalUser: User?
    private var draftUser: User?
    private var isEditingProfile = false
    
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
        view.backgroundColor = .systemGroupedBackground
        
        // Initialize state
        if let currentUser = UserSession.shared.currentUser {
            originalUser = currentUser
            draftUser = currentUser.copy()
        }

        setupTableView()
        setupHeader()
        setupEditButton()
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
    }

    private func setupTableView() {
        Table.delegate = self
        Table.dataSource = self
        Table.tableFooterView = UIView()
        Table.tableHeaderView = Cellview

    }

    private func setupHeader() {
        guard let user = originalUser else { return }
        let imageName = user.profileImageString
        Imageview.image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
        Imageview.layer.cornerRadius = Imageview.frame.height / 2
        Imageview.clipsToBounds = true
        Imageview.contentMode = .scaleAspectFill
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
