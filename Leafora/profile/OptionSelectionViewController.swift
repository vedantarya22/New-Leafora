import UIKit

class OptionSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var Imageview: UIImageView! // reused PersonalInfoVC outlet
    @IBOutlet weak var Cellview: UIView!      // reused PersonalInfoVC outlet
    @IBOutlet weak var Table: UITableView!    // reused PersonalInfoVC outlet

    var preferenceType: GardeningPreferenceType?
    var currentValue: String?

    var onSelectionChanged: ((String) -> Void)?

    private var options: [String] {
        return preferenceType?.options ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = preferenceType?.rawValue ?? "Select Option"
        
        // hide reused header for simple single-select list
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let option = options[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = option
        cell.contentConfiguration = content
        
        // show checkmark for selected value
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
        
        // send selection back to parent
        onSelectionChanged?(selectedOption)
        
        // reload to refresh checkmarks
        tableView.reloadData()
        
        // return right away after selection
        navigationController?.popViewController(animated: true)
    }
}
