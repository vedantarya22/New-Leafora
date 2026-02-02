import UIKit

// 👇 We added the Protocols here to fix the "Cannot assign value" error
class EditProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var cameraBadgeView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var personalityTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    //@IBOutlet weak var signOutButton: UIButton!
    
    // Optional Ring
    //@IBOutlet weak var progressRing: CircularProgressView!

    // MARK: - Properties
    var user: User?
    
    // Data for the Picker
    let personalities = [
        "Indoor Gardener 🏠",
        "Succulent Master 🌵",
        "Outdoor Explorer 🌲",
        "Vegetable Grower 🥕",
        "Newbie Planter 🌱",
        "Floral Enthusiast 🌸"
    ]
    
    var personalityPicker = UIPickerView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        setupPicker()
        
        // Optional Ring Animation
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.progressRing?.setProgress(to: 0.70)
//        }
    }
    
    // MARK: - Setup UI
    func setupUI() {
        // 1. Profile Image
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.contentMode = .scaleAspectFill
        
        // 2. Camera Badge
        cameraBadgeView.layer.cornerRadius = 20 //cameraBadgeView.frame.height / 2
        //cameraBadgeView.layer.borderWidth = 2
        cameraBadgeView.layer.borderColor = UIColor.systemBackground.cgColor
        
        // 3. Text Fields
        styleTextField(nameTextField)
        styleTextField(usernameTextField)
        styleTextField(personalityTextField)
        
        // 4. Buttons
        saveButton.layer.cornerRadius = 20
        saveButton.clipsToBounds = true
    }
    
    func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 12
        textField.backgroundColor = UIColor.systemGray6
        textField.clipsToBounds = true
    }
    
    func setupPicker() {
        // Connect the picker
        personalityPicker.delegate = self
        personalityPicker.dataSource = self
        
        // Set Picker as input
        personalityTextField.inputView = personalityPicker
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissPicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        personalityTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    func populateData() {
        guard let user = user else { return }
        
        profileImageView.configureImage(with: user.profileImageString)
        nameTextField.text = user.name
        
        let cleanUsername = user.username.replacingOccurrences(of: "@", with: "")
        usernameTextField.text = cleanUsername
        
        // Map personality
        personalityTextField.text = user.personality
    }

    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        print("Saving: \(nameTextField.text ?? "")")
        dismiss(animated: true)
    }
    
    // MARK: - Picker Logic (Now inside the class)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return personalities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return personalities[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        personalityTextField.text = personalities[row]
    }
}
