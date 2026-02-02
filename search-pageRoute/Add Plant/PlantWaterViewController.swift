////
////  Plant_Q5ViewController.swift
////  PlantApp
////
////  Created by SDC-USER on 08/12/25.
////
//
//import UIKit
//
//class PlantWaterViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
//    
//    
//    var session : PlantQuestionSession!
//
//    @IBOutlet weak var nextButton: UIBarButtonItem!
//    @IBOutlet weak var optionsCollectionView: UICollectionView!
//    var buttonData = dataStore.getWateringOptions()
//    var selectedIndex: IndexPath?
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        optionsCollectionView.dataSource = self
//              optionsCollectionView.delegate = self
//        registerCell()
//        
//
//        // Do any additional setup after loading the view.
//    }
//    
//    @IBAction func nextButtonTapped(_ sender: Any) {
//        if selectedIndex == nil {
//            showSelectionAlert()
//            return          // Show alert
//        }
//        // Store selected watering option in the session model
//          let selectedWatering = buttonData[selectedIndex!.row].title
//
//        session.wateringAnswer = selectedWatering
//        
////     continue to next screen
//            performSegue(withIdentifier: "toNextScreen", sender: self)
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toNextScreen" {
//            if let nextVC = segue.destination as? AddPlantImageViewController{
//                nextVC.session = self.session
//            }
//        }
//    }
//    
//    
//    func registerCell() {
//        let nib = UINib(nibName: "Plant_Q4CollectionViewCell", bundle: nil)
//        optionsCollectionView.register(nib, forCellWithReuseIdentifier: "OptionButton_Cell")
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//           return buttonData.count
//       }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "OptionButton_Cell",
//                for: indexPath
//            ) as! Plant_Q4CollectionViewCell
//            
//            let item = buttonData[indexPath.row]
//            cell.configure(with: item.title)
//        
//        // Mark the cell visually if it's selected
//          if let selected = selectedIndex, selected == indexPath {
//              collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//          } else {
//              collectionView.deselectItem(at: indexPath, animated: false)
//          }
//            
//            return cell
//        }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        
//        let sidePadding: CGFloat = 40
//        let width = collectionView.frame.width - sidePadding
//        let height: CGFloat = 65
//        
//        return CGSize(width: width, height: height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//            return 20
//        }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        // Save the selected index
//        selectedIndex = indexPath
//        
//        // Refresh UI so selected cell updates
//        collectionView.reloadData()
//        
//        print("Selected option:", buttonData[indexPath.row].title)
//    }
//
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
