//
//  Plant_Q4ViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class PlantRepotViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {


    var session : PlantQuestionSession!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var optionsCollectionView: UICollectionView!
 
    
    
    var buttonData: [OptionItem] = []
      var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buttonData = dataStore.getRepottingOptions()
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        registerCell()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        if selectedIndex == nil {
            showSelectionAlert()
            return          // Show alert
        }
        
        //  Get the selected repotting option
          let selectedRepotting = buttonData[selectedIndex!.row].title

          // Save into session model
        session.repottingAnswer = selectedRepotting
        

          print("Saved repotting option:", selectedRepotting)
        

//        continue to next screen
            performSegue(withIdentifier: "toNextScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? PlantWaterViewController {
                nextVC.session = self.session
            }
        }
    }
    
    // MARK: Register Cell
        func registerCell() {
            let nib = UINib(nibName: "PlantRepotCollectionViewCell", bundle: nil)
            optionsCollectionView.register(nib, forCellWithReuseIdentifier: "PlantRepotCell")
        }
    
    // MARK: CollectionView Data Source
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return buttonData.count
        }
    
    func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantRepotCell",
                for: indexPath
            ) as! PlantRepotCollectionViewCell
            
            let item = buttonData[indexPath.row]
            cell.optionBtn.setTitle(item.title, for: .normal)   // ONLY TITLE
            
            cell.layoutIfNeeded()
        
        // Tell UICollectionView which cell is selected
           if let selected = selectedIndex, selected == indexPath {
               collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
           } else {
               collectionView.deselectItem(at: indexPath, animated: false)
           }
        
            return cell
        }
    
    
    // MARK: CollectionView Layout
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Save selected index
        selectedIndex = indexPath
        
        // Refresh UI
            collectionView.reloadData()
        
        // Animate the selected cell after reload
          if let cell = collectionView.cellForItem(at: indexPath) as? PlantRepotCollectionViewCell{
              cell.animateSelection()
          }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
