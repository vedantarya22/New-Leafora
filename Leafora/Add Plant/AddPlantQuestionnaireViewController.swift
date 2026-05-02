//
//  AddPlantQuestionnaireViewController.swift
//  search-pageRoute
//
//  Unified single-screen questionnaire for the AddPlant flow.
//  Replaces: PlantQuantityVC, PlantLightVC, PlantRepotVC, PlantWaterVC,
//            PlantPruningVC, PlantFertilizingVC.
//

import UIKit

class AddPlantQuestionnaireViewController: UIViewController,
    UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    // MARK: - Outlets (wired from storyboard)
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!

    // MARK: - Data
    var session: PlantQuestionSession!
    private var questions: [AddPlantQuestion] = []
    private var currentIndex = 0

    /// Stores selected index per question (keyed by question id)
    private var selectedIndices: [String: IndexPath] = [:]

    // MARK: - Quantity Picker (only shown for picker-type questions)
    private let pickerView = UIPickerView()
    private var quantities: [Int] = []
    private var quantity = 1
    private var pickerTopLine: UIView?
    private var pickerBottomLine: UIView?

    // MARK: - Background
    private let gradientLayer = CAGradientLayer()

    // ────────────────────────────────────────────
    // MARK: - Lifecycle
    // ────────────────────────────────────────────

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
        questions = AddPlantQuestion.buildQuestions()

        setupCollectionView()
        setupPickerView()
        setupProgressBar()
        prefillEditModeSelections()
        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // ────────────────────────────────────────────
    // MARK: - Setup
    // ────────────────────────────────────────────

    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupCollectionView() {
        optionsCollectionView.dataSource = self
        optionsCollectionView.delegate = self
        // Register cells
        optionsCollectionView.register(
            UINib(nibName: "PlantRepotCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PlantRepotCell"
        )
        optionsCollectionView.backgroundColor = .clear
    }

    private func setupPickerView() {
        // Build quantity array
        let maxAllowed = session.isEditMode ? session.originalBatchSize : 10
        quantities = Array(1...maxAllowed)
        if session.isEditMode, let existingQty = session.plantCount, existingQty >= 1, existingQty <= maxAllowed {
            quantity = existingQty
        }

        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.isHidden = true
        view.addSubview(pickerView)

        let rowHeight: CGFloat = 52
        let pickerHeight = rowHeight * 5

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalToConstant: 120),
            pickerView.heightAnchor.constraint(equalToConstant: pickerHeight)
        ])

        pickerView.selectRow(quantity - 1, inComponent: 0, animated: false)

        DispatchQueue.main.async {
            self.removePickerOverlay()
            self.addSelectionLines()
        }
    }

    private func setupProgressBar() {
        progressBar.progressTintColor = UIColor(red: 0.2141, green: 0.4902, blue: 0.1589, alpha: 1.0)
        progressBar.trackTintColor = .systemGray5
        progressBar.progress = 0.0
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
    }

    // ────────────────────────────────────────────
    // MARK: - Edit Mode Pre-fill
    // ────────────────────────────────────────────

    private func prefillEditModeSelections() {
        guard session.isEditMode else { return }

        for (i, q) in questions.enumerated() {
            switch q.id {
            case "quantity":
                // quantity is handled by the picker, not collection view
                break

            case "repotting":
                if var existing = session.repottingAnswer {
                    if existing == "Never/In nursery pot" { existing = "Never" }
                    if let idx = q.options.firstIndex(of: existing) {
                        selectedIndices[q.id] = IndexPath(row: idx, section: 0)
                    }
                }
            case "watering":
                if let existing = session.wateringAnswer,
                   let idx = q.options.firstIndex(of: existing) {
                    selectedIndices[q.id] = IndexPath(row: idx, section: 0)
                }
            case "pruning":
                if var existing = session.pruningAnswer {
                    if existing == "Recently (last week)" { existing = "Last week" }
                    if existing == "Never pruned" { existing = "Never" }
                    if let idx = q.options.firstIndex(of: existing) {
                        selectedIndices[q.id] = IndexPath(row: idx, section: 0)
                    }
                }
            case "fertilizing":
                if let existing = session.fertilizingAnswer,
                   let idx = q.options.firstIndex(of: existing) {
                    selectedIndices[q.id] = IndexPath(row: idx, section: 0)
                }
            default:
                break
            }
        }
    }

    
    // MARK: - Update UI


    private func updateUI() {
        guard currentIndex < questions.count else { return }
        let q = questions[currentIndex]

        // Question text
        questionLabel.text = q.questionText

        // Progress — account for site step (step 1) already done
        let totalSteps = questions.count + 2 // +1 site, +1 image
        let currentStep = currentIndex + 2    // site was step 1
        progressBar.setProgress(Float(currentStep) / Float(totalSteps), animated: true)
        stepLabel.text = "Step \(currentStep) of \(totalSteps)"

        // Show/hide picker vs collection view
        if q.type == .picker {
            optionsCollectionView.isHidden = true
            pickerView.isHidden = false
            pickerTopLine?.isHidden = false
            pickerBottomLine?.isHidden = false
            pickerView.reloadComponent(0)
            pickerView.selectRow(quantity - 1, inComponent: 0, animated: false)
        } else {
            optionsCollectionView.isHidden = false
            pickerView.isHidden = true
            pickerTopLine?.isHidden = true
            pickerBottomLine?.isHidden = true
            optionsCollectionView.reloadData()
        }
    }

    
    // MARK: - Next Button
   

    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        let q = questions[currentIndex]

        // Validate selection
        if q.type == .picker {
            // Picker always has a valid selection
        } else {
            guard selectedIndices[q.id] != nil else {
                showSelectionAlert()
                return
            }
        }

        // Save answer to session
        saveCurrentAnswer()

        // Advance
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            updateUI()
        } else {
            // All questions done — go to image screen
            performSegue(withIdentifier: "toNextScreen", sender: self)
        }
    }

    private func saveCurrentAnswer() {
        let q = questions[currentIndex]

        switch q.id {
        case "quantity":
            session.plantCount = quantity
            print("Saved plant quantity:", session.plantCount ?? 0)



        case "repotting":
            if let idx = selectedIndices[q.id] {
                let selected = q.options[idx.row]
                session.repottingAnswer = selected
                session.lastRepottedDate = dateFromRepottingOptionText(selected)
                print("Saved repotting:", selected)
            }

        case "watering":
            if let idx = selectedIndices[q.id] {
                let selected = q.options[idx.row]
                session.wateringAnswer = selected
                session.lastWateredDate = dateFromWateringOptionText(selected)
                print("Saved watering:", selected)
            }

        case "pruning":
            if let idx = selectedIndices[q.id] {
                let selected = q.options[idx.row]
                session.pruningAnswer = selected
                session.lastPrunedDate = dateFromPruningOptionText(selected)
                print("Saved pruning:", selected)
            }

        case "fertilizing":
            if let idx = selectedIndices[q.id] {
                let selected = q.options[idx.row]
                session.fertilizingAnswer = selected
                session.lastFertilizedDate = dateFromFertilizingOptionText(selected)
                print("Saved fertilizing:", selected)
            }

        default:
            break
        }
    }

    
    // MARK: - Date Converters (moved from individual VCs)
  

    private func dateFromRepottingOptionText(_ text: String) -> Date? {
        let today = Date()
        let cal = Calendar.current
        switch text {
        case "Last 7 days":            return cal.date(byAdding: .day, value: -7, to: today)
        case "Never":                  return nil
        case "Never/In nursery pot":   return nil
        case "About 1 month ago":      return cal.date(byAdding: .month, value: -1, to: today)
        case "About 3–6 months ago":   return cal.date(byAdding: .month, value: -4, to: today)
        case "1 year ago or more":     return cal.date(byAdding: .year, value: -1, to: today)
        default:                       return nil
        }
    }

    private func dateFromPruningOptionText(_ text: String) -> Date? {
        let today = Date()
        let cal = Calendar.current
        switch text {
        case "Last week":              return cal.date(byAdding: .day, value: -7, to: today)
        case "Recently (last week)":   return cal.date(byAdding: .day, value: -7, to: today)
        case "About 1 month ago":      return cal.date(byAdding: .month, value: -1, to: today)
        case "About 3 months ago":     return cal.date(byAdding: .month, value: -3, to: today)
        case "6 months ago or more":   return cal.date(byAdding: .month, value: -6, to: today)
        case "Never":                  return nil
        case "Never pruned":           return nil
        default:                       return nil
        }
    }

    private func dateFromFertilizingOptionText(_ text: String) -> Date? {
        let today = Date()
        let cal = Calendar.current
        switch text {
        case "Today":                  return today
        case "Yesterday":              return cal.date(byAdding: .day, value: -1, to: today)
        case "About 1 week ago":       return cal.date(byAdding: .day, value: -7, to: today)
        case "About 1 month ago":      return cal.date(byAdding: .month, value: -1, to: today)
        case "Never":                  return nil
        default:                       return nil
        }
    }

    
    // MARK: - Segue
   

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? AddPlantImageViewController {
                nextVC.session = self.session
            }
        }
    }

    
    // MARK: - CollectionView DataSource
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard currentIndex < questions.count else { return 0 }
        return questions[currentIndex].options.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let q = questions[currentIndex]
        let selectedIdx = selectedIndices[q.id]
        let isSelected = (selectedIdx == indexPath)

        // textOptions uses PlantRepotCollectionViewCell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PlantRepotCell", for: indexPath
        ) as! PlantRepotCollectionViewCell

        cell.optionBtn.setTitle(q.options[indexPath.row], for: .normal)
        cell.layoutIfNeeded()

        if isSelected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }

        return cell
    }

    // MARK: - CollectionView Delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let q = questions[currentIndex]
        selectedIndices[q.id] = indexPath

        if let cell = collectionView.cellForItem(at: indexPath) as? PlantRepotCollectionViewCell {
            cell.animateSelection()
        }

        // Reload to update visual state
        collectionView.reloadData()

        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()

        print(" Selected \(q.id):", q.options[indexPath.row])
    }

    // MARK: - CollectionView FlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sidePadding: CGFloat = 40
        let width = collectionView.frame.width - sidePadding
        let height: CGFloat = 65
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    // ────────────────────────────────────────────
    // MARK: - Picker Helpers (from PlantQuantityVC)
    // ────────────────────────────────────────────

    private func removePickerOverlay() {
        for subview in pickerView.subviews {
            if subview.frame.height <= 2 ||
               (subview.frame.height > 30 && subview.frame.height < 60 && subview.backgroundColor != .clear) {
                subview.backgroundColor = .clear
                subview.layer.borderWidth = 0
            }
        }
    }

    private func addSelectionLines() {
        let rowHeight: CGFloat = 52
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

        pickerTopLine = topLine
        pickerBottomLine = bottomLine
    }
}

// MARK: - UIPickerView DataSource & Delegate

extension AddPlantQuestionnaireViewController: UIPickerViewDataSource, UIPickerViewDelegate {

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
