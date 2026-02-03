//
//  SiteDetailViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit

class SiteDetailViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var site: MyGardenSite?
    var userPlants: [UserPlant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let site = site else {
                  print("❌ No site data received")
                  return
              }
              
              print("✅ SiteDetailViewController loaded for:", site.name)
              
              setupUI(with: site)
              loadPlantsForSite()
              setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          
          // Reload plants when returning from adding a new plant
          loadPlantsForSite()
          collectionView.reloadData()
      }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          // Reconfigure layout when view bounds change (rotation, etc.)
          configureGridLayout()
      }
      
    
    // MARK: - Setup
      
      private func setupUI(with site: MyGardenSite) {
          self.title = site.name
          
        
      }
      
    
    private func setupCollectionView() {
          collectionView.dataSource = self
          collectionView.delegate = self
          
          // Register cell
          collectionView.register(
              UINib(nibName: "SiteDetailCollectionViewCell", bundle: nil),
              forCellWithReuseIdentifier: "SiteDetailCell"
          )
          
          // Setup layout for 2 columns
          configureGridLayout()
      }
    
    private func configureGridLayout() {
            let layout = UICollectionViewFlowLayout()
            
            let spacing: CGFloat = 16
            let columns: CGFloat = 2
            let horizontalPadding: CGFloat = 16
            
            let totalSpacing = (columns - 1) * spacing + (horizontalPadding * 2)
            let availableWidth = collectionView.bounds.width - totalSpacing
            let itemWidth = floor(availableWidth / columns)
            
            // Adjust height to your card design (image + label)
            let itemHeight: CGFloat = itemWidth + 30 // Image square + label space
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.minimumInteritemSpacing = spacing
            layout.minimumLineSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: 16, left: horizontalPadding, bottom: 16, right: horizontalPadding)
            
            collectionView.collectionViewLayout = layout
        }
    
    private func loadPlantsForSite() {
          guard let siteID = site?.id else { return }
          
          // Get all UserPlants for this site
          userPlants = PlantStore.shared.plants(for: siteID)
          
          print("✅ Loaded \(userPlants.count) plants for site")
          
          // Handle empty state
          updateEmptyState()
      }
    
    private func updateEmptyState() {
        if userPlants.isEmpty {
            // Show empty state
            let emptyLabel = UILabel()
            emptyLabel.text = "No plants added yet"
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0
            emptyLabel.textColor = .systemGray
            emptyLabel.font = UIFont.systemFont(ofSize: 16)
            
            collectionView.backgroundView = emptyLabel
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    // MARK: - UICollectionViewDataSource
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return userPlants.count
       }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: "SiteDetailCell",
              for: indexPath
          ) as! SiteDetailCollectionViewCell
          
          let userPlant = userPlants[indexPath.item]
          
          // Configure cell with user plant data
          cell.configure(userPlant: userPlant)
          
          return cell
      }
    
    // MARK: - UICollectionViewDelegate
       
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let selectedUserPlant = userPlants[indexPath.item]
           
           print("✅ Tapped plant:", selectedUserPlant.plantId)
           
           // Optional: Navigate to plant detail view
            navigateToPlantDetail(for: selectedUserPlant)
       }
    
    // MARK: - Navigation
       
       private func navigateToPlantDetail(for userPlant: UserPlant) {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
           guard let plantDetailVC = storyboard.instantiateViewController(
               withIdentifier: "PlantDetailViewController"
           ) as? PlantDetailViewController else {
               print("❌ Could not instantiate PlantDetailViewController")
               return
           }
           
           // Pass the plant ID to show details
           plantDetailVC.plantId = userPlant.plantId
           
           navigationController?.pushViewController(plantDetailVC, animated: true)
           
           print("✅ Navigating to plant detail for:", userPlant.plantId)
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
