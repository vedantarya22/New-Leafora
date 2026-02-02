////
////  PlantLight_Q3ViewController.swift
////  PlantApp
////
////  Created by SDC-USER on 28/11/25.
////
//
//import UIKit
//
//class PlantLightViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
//    
////    var answers: AddPlantAnswerModel!
//    var session : PlantQuestionSession!
//    
//    
//    @IBOutlet weak var PlantLightCollectionView: UICollectionView!
//    
//    @IBOutlet weak var nextButton: UIBarButtonItem!
//    var buttonData = dataStore.getPlantLightOptions()
//    
//    var selectedIndex: IndexPath?
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//    
////        // Allow large titles to wrap into multiple lines
////        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).numberOfLines = 0
////        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).lineBreakMode = .byWordWrapping
//
//        
//        
//      
//        PlantLightCollectionView.dataSource = self
//        PlantLightCollectionView.delegate = self
//        registerCell()
//        
//    }
//    
//    
//    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
//        // Check if user selected something
//        if selectedIndex == nil {
//            showSelectionAlert()
//            return          //  show alert
//        }
//        
//        // Store selected light requirement into session model
//          let selectedLight = buttonData[selectedIndex!.row].light
//        session.plantLight = selectedLight
//
//          print("Saved Light Requirement:", selectedLight)
//        
//        
////         continue to next screen
//            performSegue(withIdentifier: "toNextScreen", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toNextScreen" {
//            if let nextVC = segue.destination as? Plant_Q4ViewController {
//                nextVC.session = self.session
//            }
//        }
//    }
//
//    
//     
//    
//    
//    
//    func registerCell() {
//        let nib = UINib(nibName: "Add_plant_lightCollectionViewCell", bundle: nil)
//        PlantLightCollectionView.register(nib, forCellWithReuseIdentifier: "PlantLight_Cell")
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return buttonData.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantLight_Cell", for: indexPath) as! Add_plant_lightCollectionViewCell
//        let item = buttonData[indexPath.row]
//        cell.plantLightButton.setTitle(item.light, for: .normal)
//        cell.plantLightButton.setImage(UIImage(systemName: item.image), for: .normal)
//        
//        cell.layoutIfNeeded()
//        
//        // Tell CollectionView which cell is selected
//           if let selected = selectedIndex, selected == indexPath {
//               collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//           } else {
//               collectionView.deselectItem(at: indexPath, animated: false)
//           }
//        
//        
//        return cell
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let sidePadding: CGFloat = 40
//        let width = collectionView.frame.width - sidePadding
//          let height: CGFloat = 65
//        
//        return CGSize(width: width, height: height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20   // spacing between cells vertically
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        // Save selected index
//        selectedIndex = indexPath
//        
//        // Refresh UI
//            collectionView.reloadData()
//        
//        // Animate the selected cell after reload
//          if let cell = collectionView.cellForItem(at: indexPath) as? Add_plant_lightCollectionViewCell {
//              cell.animateSelection()
//          }
//        
//    }
//
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
//
//
