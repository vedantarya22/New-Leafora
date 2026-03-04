import UIKit

class PlantQuantityViewController: UIViewController {

    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    var session: PlantQuestionSession!
    var quantity = 1

    private let pickerView = UIPickerView()
    private let quantities = Array(1...10)

    override func viewDidLoad() {
        super.viewDidLoad()

        // ✏️ Pre-select existing quantity in edit mode
        if session.isEditMode, let existingQty = session.plantCount, existingQty >= 1, existingQty <= 10 {
            quantity = existingQty
        }

        setupPicker()
        minusBtn.isHidden = true
        plusBtn.isHidden = true
        qtyLabel.isHidden = true
    }

    private func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.selectRow(quantity - 1, inComponent: 0, animated: false)

        // ✅ Remove the default grey ellipse selection overlay
        pickerView.subviews.forEach { subview in
            if subview.frame.height < 2 {
                subview.backgroundColor = .clear
            }
        }

        view.addSubview(pickerView)

        // 5 rows visible: 2 above + 1 selected + 2 below = rowHeight * 5
        let rowHeight: CGFloat = 52
        let pickerHeight = rowHeight * 5

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 120),
            pickerView.heightAnchor.constraint(equalToConstant: pickerHeight)
        ])

        DispatchQueue.main.async {
            self.removePickerOverlay()
            self.addSelectionLines()
        }
    }

    private func removePickerOverlay() {
        // Remove the default selection indicator (capsule/ellipse)
        for subview in pickerView.subviews {
            if subview.frame.height <= 2 || (subview.frame.height > 30 && subview.frame.height < 60 && subview.backgroundColor != .clear) {
                subview.backgroundColor = .clear
                subview.layer.borderWidth = 0
            }
        }
    }

    private func addSelectionLines() {
        let rowHeight: CGFloat = 52
        // Lighter green
        let lineColor = UIColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.45)

        let topLine = UIView()
        topLine.backgroundColor = lineColor
        topLine.translatesAutoresizingMaskIntoConstraints = false

        let bottomLine = UIView()
        bottomLine.backgroundColor = lineColor
        bottomLine.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(topLine)
        view.addSubview(bottomLine)

        NSLayoutConstraint.activate([
            topLine.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor),
            topLine.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor, constant: -(rowHeight / 2)),
            topLine.widthAnchor.constraint(equalTo: pickerView.widthAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 1),

            bottomLine.centerXAnchor.constraint(equalTo: pickerView.centerXAnchor),
            bottomLine.centerYAnchor.constraint(equalTo: pickerView.centerYAnchor, constant: (rowHeight / 2)),
            bottomLine.widthAnchor.constraint(equalTo: pickerView.widthAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        session.plantCount = quantity
        print("Saved plant quantity:", session.plantCount)
        performSegue(withIdentifier: "toNextScreen", sender: self)
    }

    @IBAction func didTapMinus(_ sender: UIButton) {}
    @IBAction func didTapPlus(_ sender: UIButton) {}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? PlantLightViewController {
                nextVC.session = self.session
            }
        }
    }
}

// MARK: - UIPickerView
extension PlantQuantityViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        quantities.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let distance = abs(row - selectedRow)

        let label = UILabel()
        label.text = "\(quantities[row])"
        label.textAlignment = .center
        label.backgroundColor = .clear

        switch distance {
        case 0:
            label.font = UIFont.systemFont(ofSize: 34, weight: .semibold)
            label.textColor = UIColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 1)
        case 1:
            label.font = UIFont.systemFont(ofSize: 26, weight: .regular)
            label.textColor = UIColor.secondaryLabel.withAlphaComponent(0.55)
        case 2:
            label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            label.textColor = UIColor.tertiaryLabel.withAlphaComponent(0.4)
        default:
            label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            label.textColor = .clear
        }

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 52
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        quantity = quantities[row]
        pickerView.reloadComponent(0)
        pickerView.selectRow(row, inComponent: 0, animated: false)
    }
}
