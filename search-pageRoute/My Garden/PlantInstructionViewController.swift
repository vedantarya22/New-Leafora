import UIKit

class PlantInstructionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var plantId: String?
    var selectedPlant: Plant?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Basic UI setup
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white
        
        // This allows the image to go behind the status bar (top of screen)
        collectionView.contentInsetAdjustmentBehavior = .never
        
        setupCollectionView()
        loadPlantData()
    }

    private func loadPlantData() {
        // Use your existing JSON loader to get the Areca Palm details
        guard let id = plantId else { return }
        self.selectedPlant = JSONLoader.plant(by: id)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 2. Register the Header Class (Step 3 from previous message)
        // We register the CLASS first to ensure no XIB connection crashes
        // MUST look like this:
        let nib = UINib(nibName: "PlantDashboardHeader", bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PlantDashboardHeader")
        
        // 3. Register a dummy cell just so the collection view has content
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }

    // MARK: - Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5 // Just for testing scroll
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .white
        return cell
    }

    // MARK: - Header Logic (The Plant Info)

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PlantDashboardHeader", for: indexPath) as! PlantDashboardHeader
            
            // Hardcode "areca_palm" for a second just to prove it works
            header.configure(with: "Areca Palm", variety: "Golden Cane", imageName: "areca_palm")
            
            return header
        }
        return UICollectionReusableView()
    }

    // MARK: - Layout (The Size)

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // This is the height of your Hero Image + Content Card
        return CGSize(width: collectionView.frame.width, height: 750)
    }
}
