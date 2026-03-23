//
//  Add-Plant-Ques-1ViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class PlantSiteViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    let siteStore = SiteStore.shared
    
    var plantId: String?
    var session: PlantQuestionSession!
    
    @IBOutlet weak var siteOptionsCollectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    var buttondata: [PlantSiteOption] = []
    var selectedIndex: IndexPath?
    var selectedSite: String?
    var selectedIcon: String?

   

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBotanicalBackground()
                
        

        buttondata = dataStore.getQues1button()
        // Do any additional setup after loading the view.
        siteOptionsCollectionView.dataSource = self
        siteOptionsCollectionView.delegate = self
       
        registerCell()
        if session == nil, let plantId = plantId {
                session = PlantQuestionSession(plantId: plantId)
            }

        // ✏️ Pre-select existing site in edit mode
        if session.isEditMode, let existingSite = session.siteName {
            if let index = buttondata.firstIndex(where: { $0.site == existingSite }) {
                selectedIndex = IndexPath(row: index, section: 0)
                selectedSite = existingSite
                selectedIcon = buttondata[index].image
            }
        }
            
            print("PlantSiteViewController loaded with plantID:", plantId ?? "nil")
    }
    
    private let gradientLayer = CAGradientLayer()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupBotanicalBackground() {
        let topColor = UIColor(red: 0.96, green: 0.98, blue: 0.96, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 0.88, green: 0.94, blue: 0.89, alpha: 1.0).cgColor
        
        gradientLayer.colors = [topColor, bottomColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        // site selected by user
        guard let _ = selectedIndex else {
               showSelectionAlert()
               return
           }
        
        // Use the selectedSite property if it has been set (important for custom sites!)
        // Otherwise, fall back to the button data.
        let finalSite = self.selectedSite ?? buttondata[selectedIndex!.row].site
        let finalIcon = self.selectedIcon ?? buttondata[selectedIndex!.row].image
        
        
        session.siteName = finalSite
        session.siteIcon = finalIcon   // selected icon mapping
        
        //  Go to next screen
            performSegue(withIdentifier: "toNextScreen", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNextScreen" {
            if let nextVC = segue.destination as? AddPlantQuestionnaireViewController {
                nextVC.session = self.session // session model passing
            }
        }
    }

    
    
    
    
    func registerCell() {
           siteOptionsCollectionView.register(
               UINib(nibName: "PlantSiteCollectionViewCell", bundle: nil),
               forCellWithReuseIdentifier: "PlantSiteCell"
           )
       }
       
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttondata.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantSiteCell", for: indexPath) as! PlantSiteCollectionViewCell
        let item = buttondata[indexPath.row]
        
        
        cell.plantSiteLabel.text = item.site
        cell.plantSiteButton.setImage(UIImage(systemName: item.image), for: .normal)
        // Let the cell handle its own tintColor based on selection state
        
        // Tell CollectionView which cell is selected
           if let selected = selectedIndex, selected == indexPath {
               collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
           } else {
               collectionView.deselectItem(at: indexPath, animated: false)
           }
        return cell
    }
    
   
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath : IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 40 // left + right + inter-item spacing
           let itemWidth = (collectionView.frame.width - totalSpacing) / 3

           return CGSize(width: itemWidth, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == buttondata.count-1{
            presentCustomSiteModal()
            return
        }
        
        
        // Save selected index
        selectedIndex = indexPath
        selectedSite = buttondata[indexPath.row].site
        selectedIcon = buttondata[indexPath.row].image
        
        // Refresh UI
            collectionView.reloadData()
        
        // Animate the selected cell after reload
          if let cell = collectionView.cellForItem(at: indexPath) as? PlantLightCollectionViewCell{
              cell.animateSelection()
          }
        print("✅ Selected site:", selectedSite ?? "None")
    }
    
    func presentCustomSiteModal() {
        let vc = CustomSiteModalViewController(nibName: "CustomSiteModalViewController", bundle: nil)
              
              if let sheet = vc.sheetPresentationController {
                  sheet.detents = [.medium()]
                  sheet.prefersGrabberVisible = true
                  sheet.preferredCornerRadius = 35
              }
              
              vc.onSiteEntered = { [weak self] customName in
                  guard let self = self else { return }
                  
                  // Save custom site
                  self.selectedSite = customName
                  self.selectedIcon = "plus.circle.fill"
                  
                  // Mark "Custom Site" option as selected (last item)
                  self.selectedIndex = IndexPath(row: self.buttondata.count - 1, section: 0)
                  
                  // Reload UI
                  self.siteOptionsCollectionView.reloadData()
                  
                  print("✅ Custom site selected:", customName)
              }
              
              present(vc, animated: true)
    }
    
    
    
    
   

}
