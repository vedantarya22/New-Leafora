//
//  ViewController.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

class PlantDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var plantId: String?
    var plants: [Plant] = []
    var currentPlant: Plant? {
        plants.first
    }
   
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Load plants from JSON
//        plants = JSONLoader.loadPlants(from: "plantData")

        print("Plants loaded:", plants.count)
//        print(plants)
        
        loadSpecificPlant()
        
//        setupGradient()
        setupCollectionView()
    }
    
    func loadSpecificPlant() {
            // Load ALL plants first
            let allPlants = JSONLoader.loadPlants(from: "plantData")
        print("DEBUG: Received Plant ID from Search: '\(plantId ?? "NIL")'")
            
            // Check if an ID was passed
            if let id = plantId {
                // Filter to find the matching plant
                if let foundPlant = allPlants.first(where: { $0.plantId == id }) {
                    self.plants = [foundPlant] // Set array to contain ONLY the selected plant
                } else {
                    print("Error: Plant with ID \(id) not found.")
                    self.plants = [] // Or handle error state
                }
            } else {
                // Fallback: If no ID passed, maybe show all or empty
                print("No Plant ID passed, defaulting to first plant in JSON")
                if let first = allPlants.first {
                    self.plants = [first]
                }
            }
        
        collectionView.reloadData()
            
            // Set Title
            self.title = currentPlant?.plantName
            print("Detail View Loaded for: \(currentPlant?.plantName ?? "Unknown")")
        }
    
    
    private func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "HeroImageCell", bundle: nil),
                                forCellWithReuseIdentifier: "HeroImageCell")
        
//        collectionView.register(UINib(nibName: "PlantTitleCell", bundle: nil),
//                                forCellWithReuseIdentifier: "PlantTitleCell")
        
        collectionView.register(UINib(nibName: "PlantAboutCell", bundle: nil),
                                forCellWithReuseIdentifier: "PlantAboutCell")
        
        collectionView.register(UINib(nibName: "FeatureCell", bundle: nil),
                                forCellWithReuseIdentifier: "FeatureCell")
        
        collectionView.register(UINib(nibName: "PlantCareCell", bundle: nil),
                                forCellWithReuseIdentifier: "PlantCareCell")
        
        collectionView.register(UINib(nibName: "PlantSoilCell", bundle: nil),
                                forCellWithReuseIdentifier: "PlantSoilCell")
        
        collectionView.register(UINib(nibName: "PlantIssueCell", bundle: nil),
                                forCellWithReuseIdentifier: "PlantIssueCell")
        collectionView.register(UINib(nibName: "PlantActionButtonCell", bundle: nil),
                                forCellWithReuseIdentifier: "PlantActionButtonCell")
        
        collectionView.register(UINib(nibName: "SectionHeaderView", bundle: nil),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "SectionHeaderView")
        
        collectionView.collectionViewLayout = createLayout()
    }
    
    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            let section = PlantDetailSection(rawValue: sectionIndex)!
            
            if section == .feature{
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3), heightDimension: .absolute(120)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                       item.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
                
                let groupSize = NSCollectionLayoutSize(
                               widthDimension: .fractionalWidth(1),
                               heightDimension: .absolute(120)
                           )
                let group = NSCollectionLayoutGroup.horizontal(
                               layoutSize: groupSize,
                               subitems: [item]
                           )
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)

                          return sectionLayout
            }
            
            if section == .heroImage {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(260)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )

                let sectionLayout = NSCollectionLayoutSection(group: group)

                // ONLY left & right margin
                sectionLayout.contentInsets = .init(top: 0, leading: 8, bottom: 16, trailing: 8)

                return sectionLayout
            }
            
            if section == .buttons {
                        let itemSize = NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60) // Standard button height
                        )
                        let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 2, leading: 12, bottom: 2, trailing: 12)
                        
                        let group = NSCollectionLayoutGroup.vertical(
                            layoutSize: itemSize,
                            subitems: [item]
                        )
                        
                        let sectionLayout = NSCollectionLayoutSection(group: group)
                        sectionLayout.contentInsets = .init(top: 4, leading: 0, bottom: 16, trailing: 0)
                
                        return sectionLayout
                    }
            
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(120)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)
     
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
            if section.hasHeader {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(40)
                )
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                sectionLayout.boundarySupplementaryItems = [header]
            }
            
            return sectionLayout
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        PlantDetailSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let plant = currentPlant else { return 0 }
        let sec = PlantDetailSection(rawValue: section)!
        switch sec {
        case .heroImage,.about:
            return 1
        case .feature:
            return 3
        case .care:
            return plants[0].careCycle.rows.count
        case .soil:
            return 2
        case .issues:
             return plants[0].commonIssues.count
        case .buttons :
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let plant = currentPlant else {
                    return UICollectionViewCell() // Return empty cell if data is missing to prevent crash
                }
        let section = PlantDetailSection(rawValue: indexPath.section)!
        
        switch section {
            
        case .heroImage:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "HeroImageCell",
                for: indexPath) as! HeroImageCell
            cell.configure(with: plant )
            return cell
//            
//        case .titleInfo:
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "PlantTitleCell",
//                for: indexPath) as! PlantTitleCell
//            let plant = plants[0]
//            cell.configure(with: plant)
//            return cell
            
        case .about:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantAboutCell",
                for: indexPath) as! PlantAboutCell
          
            cell.configure(with : plant)
            return cell
            
        case .feature:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "FeatureCell",
                for: indexPath) as! FeatureCell

               let features: [FeatureType] = [.light, .petFriendly, .toxic]

               cell.configure(
                   type: features[indexPath.item],
                   plant: plant
               )
            return cell
            
        case .care:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantCareCell",
                for: indexPath) as! PlantCareCell
            
            let row = plant.careCycle.rows[indexPath.row]
            let isFirst = indexPath.item == 0
            let isLast = indexPath.item == plant.careCycle.rows.count - 1

            cell.configure(
                   type: row.type,
                   value: row.value,
                   isLast: isLast
               )
            cell.applyCorners(isFirst: isFirst, isLast: isLast)

            return cell
            
        case .soil:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantSoilCell",
                for: indexPath) as! PlantSoilCell
              let values = plant.soilType.values
            
            let isFirst = indexPath.item == 0
            let isLast = indexPath.item == values.count - 1

              cell.configure(value:values[indexPath.item],isLast: isLast)
            cell.applyCorners(isFirst: isFirst, isLast: isLast)
            return cell
            
        case .issues:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantIssueCell",
                for: indexPath) as! PlantIssueCell
    
            let issues = plant.commonIssues
               let isFirst = indexPath.item == 0
               let isLast = indexPath.item == issues.count - 1

               cell.configure(issue: issues[indexPath.item],isLast: isLast)
               cell.applyCorners(isFirst: isFirst, isLast: isLast)

            return cell
            
        case .buttons:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PlantActionButtonCell",
                for: indexPath
            ) as! PlantActionButtonCell

            if indexPath.row == 0 {
                cell.configure(type: .addPlant)
                cell.onTap = {
                    print("✅ Add Plant button tapped")
                }
            } else {
                cell.configure(type: .visualizeAR)
                cell.onTap = {
                    print("🧩 AR View button tapped")
                }
            }
            return cell

            
        }
        
    }
    

    
 
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "SectionHeaderView", for:indexPath) as! SectionHeaderView
        
        let section = PlantDetailSection(rawValue: indexPath.section)!
        header.titleLabel.text = section.headerTitle
        
        return header
    }
    
}
