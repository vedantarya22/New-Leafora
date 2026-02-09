//
//  PlantLight_Q3ViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class PlantLightViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
//    var answers: AddPlantAnswerModel!
    var session : PlantQuestionSession!
    
    
    @IBOutlet weak var PlantLightCollectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    var buttonData: [PlantLightOption] = []
       var selectedIndex: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlantLightCollectionView.dataSource = self
        PlantLightCollectionView.delegate = self
        registerCell()
        print("✅ PlantLightViewController loaded with session for plantID:", session.plantId)
        
        // ✅ Load options into buttonData
        buttonData = dataStore.getPlantLightOptions()

           // ✅ Reload collection view
           PlantLightCollectionView.reloadData()

        
    }
    
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        // Check if user selected something
        if selectedIndex == nil {
            showSelectionAlert()
            return          //  show alert
        }
        
        // Store selected light requirement into session model
          let selectedLight = buttonData[selectedIndex!.row].light
        session.plantLight = selectedLight

          print("Saved Light Requirement:", selectedLight)
        
        
//         continue to next screen
            performSegue(withIdentifier: "toNextScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? PlantRepotViewController {
                nextVC.session = self.session
            }
        }
    }

    
     
    
    
    
    func registerCell() {
        let nib = UINib(nibName: "PlantLightCollectionViewCell", bundle: nil)
        PlantLightCollectionView.register(nib, forCellWithReuseIdentifier: "PlantLightCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantLightCell", for: indexPath) as! PlantLightCollectionViewCell
        let item = buttonData[indexPath.row]
        
        // Use modern UIButton Configuration for the icon + text layout
        var config = UIButton.Configuration.plain()
        config.title = item.light
        config.image = UIImage(systemName: item.image)
        config.imagePadding = 12
        config.baseForegroundColor = .label
        
        cell.plantLightButton.configuration = config
        
        // Handle the initial state without reloadData
        cell.isSelected = (selectedIndex == indexPath)
        
        return cell
    }
    
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
        return 20   // spacing between cells vertically
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1. Store selection logic
        selectedIndex = indexPath
        
        // 2. Animate only the cell that was touched
        if let cell = collectionView.cellForItem(at: indexPath) as? PlantLightCollectionViewCell {
            cell.animateSelection()
        }
        
        // 3. Keep logic intact
        print("✅ Selected light:", buttonData[indexPath.row].light)
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


