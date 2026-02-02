////
////  Add-Plant-Ques-1ViewController.swift
////  PlantApp
////
////  Created by SDC-USER on 26/11/25.
////
//
//import UIKit
//
//class PlantSiteViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//    
//    
//    let siteStore = SiteStore.shared
//    
//    var plantId: String?
//    var session: PlantQuestionSession!
//    
//    @IBOutlet weak var siteOptionsCollectionView: UICollectionView!
//    
//    @IBOutlet weak var nextButton: UIBarButtonItem!
//    var buttondata = dataStore.getQues1button()
//    var selectedIndex: IndexPath?
//    var selectedSite: String?
//
//   
//
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//                
//        
//
//        
//        // Do any additional setup after loading the view.
//        siteOptionsCollectionView.dataSource = self
//        siteOptionsCollectionView.delegate = self
//       
//        registerCell()
//        if session == nil, let plantId = plantId {
//                    session = PlantQuestionSession(plantId: plantId)
//                }
//
//            print("Received plantID:", plantId ?? "nil")
//    }
//    
//    
//    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
//        // site selected by user
//        guard let selectedIndex = selectedIndex else {
//               showSelectionAlert()
//               return
//           }
//        
//        let selectedSite = buttondata[selectedIndex.row].site
//        let selectedIcon = buttondata[selectedIndex.row].image
//        
//        
//        session.siteName = selectedSite
//        session.siteIcon = selectedIcon   // selected icon mapping
//        
//        //  Go to next screen
//            performSegue(withIdentifier: "toNextScreen", sender: self)
//        
//    }
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toNextScreen" {
//            if let nextVC = segue.destination as? PlantLightViewController {
//                nextVC.session = self.session // session model passing
//            }
//        }
//    }
//
//    
//    
//    
//    
//    func registerCell(){
//        siteOptionsCollectionView.register(UINib(nibName: "addplantbuttonCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "addSite_cell")
//        
//    }
//    
//   
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return buttondata.count
//    }
//    
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addSite_cell", for: indexPath) as! addplantbuttonCollectionViewCell
//        let item = buttondata[indexPath.row]
//        
//        
//        cell.plantSiteLabel.text = item.site
//        cell.plantSiteButton.setImage(UIImage(systemName: item.image), for: .normal)
//        cell.plantSiteButton.tintColor = .black
//        
//        // Tell CollectionView which cell is selected
//           if let selected = selectedIndex, selected == indexPath {
//               collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
//           } else {
//               collectionView.deselectItem(at: indexPath, animated: false)
//           }
//        return cell
//    }
//    
//   
//    
//    
//    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath : IndexPath) -> CGSize {
//        let totalSpacing: CGFloat = 40 // left + right + inter-item spacing
//           let itemWidth = (collectionView.frame.width - totalSpacing) / 3
//
//           return CGSize(width: itemWidth, height: 120)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 20
//    }
//    
//   
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.row == buttondata.count-1{
//            presentCustomSiteModal()
//            return
//        }
//        
//        
//        // Save selected index
//        selectedIndex = indexPath
//        // Store selected site string
//        selectedSite = buttondata[indexPath.row].site
//        
//        // Refresh UI
//            collectionView.reloadData()
//        
//        // Animate the selected cell after reload
//          if let cell = collectionView.cellForItem(at: indexPath) as? addplantbuttonCollectionViewCell {
//              cell.animateSelection()
//          }
//        print("Selected site:", selectedSite)
//    }
//    
//    func presentCustomSiteModal() {
//        let vc = CustomSiteModalViewController(nibName: "CustomSiteModalViewController", bundle: nil)
//         
//         if let sheet = vc.sheetPresentationController {
//             sheet.detents = [.medium()]               // half screen
//             sheet.prefersGrabberVisible = true        // small grab handle at top
//             sheet.preferredCornerRadius = 35
//         }
//        
//        vc.onSiteEntered = { [weak self] customName in
//                guard let self = self else { return }
//
//                // Save custom site text
//                self.selectedSite = customName
//                
//                //  Mark last item (Custom Site) as selected
//                self.selectedIndex = IndexPath(row: self.buttondata.count - 1, section: 0)
//                
//                //  Reloading UI to reflect selection
//                self.siteOptionsCollectionView.reloadData()
//
//                print("Custom site selected:", customName)
//            }
//         
//         present(vc, animated: true)
//    }
//    
//    
//    
//    
//   
//
//}
