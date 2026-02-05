import UIKit

class SiteDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var site: MyGardenSite?
    var userPlants: [UserPlant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = site?.name
        setupCollectionView()
        loadPlantsForSite()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "SiteDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SiteDetailCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        collectionView.collectionViewLayout = layout
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = collectionView.bounds.width - 32
            layout.itemSize = CGSize(width: width, height: 110) // Perfect height for this card
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
    }
    
    private func loadPlantsForSite() {
        guard let siteID = site?.id else { return }
        userPlants = PlantStore.shared.plants(for: siteID)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteDetailCell", for: indexPath) as! SiteDetailCollectionViewCell
        cell.configure(userPlant: userPlants[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUserPlant = userPlants[indexPath.item]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Ensure Storyboard ID in Identity Inspector is "PlantInstructionViewController"
        guard let instructionVC = storyboard.instantiateViewController(
            withIdentifier: "PlantInstructionViewController"
        ) as? PlantInstructionViewController else {
            print("❌ Error: Check Storyboard ID for PlantInstructionViewController")
            return
        }
        
        // Pass the plant data
        instructionVC.plantId = selectedUserPlant.plantId
        
        // Push the new screen
        navigationController?.pushViewController(instructionVC, animated: true)
    }
    private func navigateToPlantDetail(for userPlant: UserPlant) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "PlantDetailViewController") as? PlantDetailViewController {
            detailVC.plantId = userPlant.plantId
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
