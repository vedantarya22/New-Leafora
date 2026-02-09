////
//  MyGardenViewController.swift
//  PlantApp
//
//  Created by SDC-USER on 26/11/25.
//
import UIKit

class MyGardenViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var myGardenCollectionView: UICollectionView!
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No sites yet.\nAdd plants to get started "
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let siteStore = SiteStore.shared

   
    override func viewDidLoad() {
         super.viewDidLoad()
         
         setupCollectionView()
        setupEmptyStateLabel()
         updateEmptyState()
     }
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        myGardenCollectionView.reloadData()
        updateEmptyState()
    }

    
    private func setupEmptyStateLabel() {
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }

    
    private func setupCollectionView() {
           myGardenCollectionView.delegate = self
           myGardenCollectionView.dataSource = self
           registerCell()
           configureGridLayout()
       }
   
    private func registerCell(){
        myGardenCollectionView.register(UINib(nibName: "MyGardenCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyGardenCell")
    }
    
    
    private func configureGridLayout() {
        let layout = UICollectionViewFlowLayout()

        let spacing: CGFloat = 16
        let columns: CGFloat = 2

        // padding from left & right
        let horizontalPadding: CGFloat = 16

        let totalSpacing = (columns - 1) * spacing + (horizontalPadding * 2)
        let itemWidth = floor((myGardenCollectionView.bounds.width - totalSpacing) / columns)

        layout.itemSize = CGSize(width: itemWidth, height: 100)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: horizontalPadding, bottom: 16, right: horizontalPadding)

        myGardenCollectionView.collectionViewLayout = layout
    }
    
    
  
 
    
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           configureGridLayout()
       }
    
    private func updateEmptyState() {
        let isEmpty = siteStore.sites.isEmpty

        emptyStateLabel.isHidden = !isEmpty
        myGardenCollectionView.isHidden = isEmpty
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return siteStore.sites.count
       }
    
    func collectionView(_ collectionView: UICollectionView,
                           cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

           let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: "MyGardenCell",
               for: indexPath
           ) as! MyGardenCollectionViewCell
           
           let site = siteStore.sites[indexPath.item]
           
           // Configure UI
            cell.iconButton.setImage(UIImage(systemName: site.icon), for: .normal)

           cell.siteNameLabel.text = site.name

           
       
        // Calculate total plant count for this site (including quantities)
               let plantsInSite = PlantStore.shared.plants(for: site.id)
               let totalCount = plantsInSite.reduce(0) { $0 + $1.quantity }
               cell.plantCountLabel.text = "\(totalCount) plant\(totalCount == 1 ? "" : "s")"
               
           
               
               return cell


           
       
       }
   
       
    
    // MARK: Select site → Push detail page
      
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          
          let selectedSite = siteStore.sites[indexPath.item]
                 
                 print("✅ Tapped site:", selectedSite.name)
                 print("✅ Site ID:", selectedSite.id)
                 print("✅ Navigation Controller:", navigationController != nil ? "Available" : "NIL")
                 
                 // Navigate to Site Detail
                 navigateToSiteDetail(for: selectedSite)
      }
    
    
    private func navigateToSiteDetail(for site: MyGardenSite) {
        let storyboard = UIStoryboard(name: "MyGarden", bundle: nil)
        
        guard let vc = storyboard.instantiateViewController(
            withIdentifier: "SiteDetailViewController"
        ) as? SiteDetailViewController else {
            print("❌ Could not instantiate SiteDetailViewController")
            return
        }
        
        vc.site = site
        
        if let navController = navigationController {
            navController.pushViewController(vc, animated: true)
            print("✅ Navigating to SiteDetailViewController for site:", site.name)
        } else {
            print("❌ Navigation Controller is nil - cannot push")
        }
        
    }

    
   

    

       

}
