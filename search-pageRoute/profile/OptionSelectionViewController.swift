import UIKit

class OptionSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Imageview: UIImageView! // From reused PersonalInfoVC
    @IBOutlet weak var Cellview: UIView!      // From reused PersonalInfoVC
    @IBOutlet weak var Table: UITableView!    // From reused PersonalInfoVC

    var preferenceType: GardeningPreferenceType?
    var currentValue: String?

    var onSelectionChanged: ((String) -> Void)?

    private var options: [String] {
        return preferenceType?.options ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = preferenceType?.rawValue ?? "Select Option"
        
        // We reuse the PersonalInfoVC layout but we might want to hide the header image if not needed.
        // The user said: "simple single-selection list (similar to the iOS Repeat screen)".
        // Usually these don't have a big header image.
        // So let's hide the table header view.
        Table.tableHeaderView = nil
        
        setupTableView()
    }

    private func setupTableView() {
        Table.delegate = self
        Table.dataSource = self
        Table.tableFooterView = UIView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Reuse the same identifier "cell" from the storyboard
        // Since this VC is reused from Personal_InfoViewController, check that cell class.
        // It was PersonalInfoTableViewCell.
        // However, for this simple list, we don't need the text field.
        // We can just use the cell's basic properties or standard config.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // If it's a PersonalInfoTableViewCell, we might need to cast to access outlets if we wanted to use them,
        // but since we want a standard look, let's use content configuration which overrides custom subclass views usually.
        
        let option = options[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = option
        cell.contentConfiguration = content
        
        // Show checkmark if selected
        if option == currentValue {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedOption = options[indexPath.row]
        currentValue = selectedOption
        
        // Notify parent via callback
        onSelectionChanged?(selectedOption)
        
        // Reload to update checkmarks
        tableView.reloadData()
        
        // Return to previous screen immediately as per standard iOS selection behavior
        navigationController?.popViewController(animated: true)
    }
}
