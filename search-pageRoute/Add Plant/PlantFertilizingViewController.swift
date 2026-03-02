//
//  PlantFertilizingViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 02/03/26.
//


import UIKit

class PlantFertilizingViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var session: PlantQuestionSession!

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var optionsCollectionView: UICollectionView!

    var buttonData: [OptionItem] = []
    var selectedIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonData = dataStore.getFertilizingOptions()
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        registerCell()
    }

    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        if selectedIndex == nil {
            showSelectionAlert()
            return
        }
        let selected = buttonData[selectedIndex!.row].title
        session.fertilizingAnswer = selected
        session.lastFertilizedDate = dateFromFertilizingOptionText(selected)
        print("Saved fertilizing:", selected)
        performSegue(withIdentifier: "toNextScreen", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? PlantPruningViewController {
                nextVC.session = self.session
            }
        }
    }

    func dateFromFertilizingOptionText(_ text: String) -> Date? {
        let today = Date()
        let cal = Calendar.current
        switch text {
        case "Today":             return today
        case "Yesterday":         return cal.date(byAdding: .day, value: -1, to: today)
        case "About 1 week ago":  return cal.date(byAdding: .day, value: -7, to: today)
        case "About 1 month ago": return cal.date(byAdding: .month, value: -1, to: today)
        default:                  return nil
        }
    }

    func registerCell() {
        let nib = UINib(nibName: "PlantRepotCollectionViewCell", bundle: nil)
        optionsCollectionView.register(nib, forCellWithReuseIdentifier: "PlantRepotCell")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { buttonData.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantRepotCell", for: indexPath) as! PlantRepotCollectionViewCell
        cell.optionBtn.setTitle(buttonData[indexPath.row].title, for: .normal)
        cell.layoutIfNeeded()
        if let selected = selectedIndex, selected == indexPath {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width - 40, height: 65)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 20 }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let selected = buttonData[indexPath.row].title
        session.fertilizingAnswer = selected
        session.lastFertilizedDate = dateFromFertilizingOptionText(selected)
        if let cell = collectionView.cellForItem(at: indexPath) as? PlantRepotCollectionViewCell {
            cell.animateSelection()
        }
        nextButton.isEnabled = true
    }
}