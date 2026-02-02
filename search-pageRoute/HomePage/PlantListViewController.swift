import UIKit

class PlantListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var taskType: String = ""
    var filteredPlants: [Plant] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = taskType
        
        // 1. Register the new XIB
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadAndFilterData()
    }

    // 2. Make it look like a Table View (Full Width)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPlants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantRowCell", for: indexPath) as! PlantRowCell
        let plant = filteredPlants[indexPath.row]
        
        cell.configure(with: plant, task: taskType)
        
        // Updated closure to prevent index out of range
        cell.onDone = { [weak self, weak cell] in
            guard let self = self, let currentCell = cell else { return }
            
            // 1. Ask the collectionView for the NEW index of this specific cell
            guard let currentIndexPath = self.collectionView.indexPath(for: currentCell) else { return }
            
            // 2. Safety check: Ensure the index is still within bounds
            if currentIndexPath.row < self.filteredPlants.count {
                // 3. Remove from data source using the fresh index
                self.filteredPlants.remove(at: currentIndexPath.row)
                
                // 4. Animate the deletion
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [currentIndexPath])
                }, completion: nil)
            }
        }
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Only perform the hint if there are plants in the list
        if !filteredPlants.isEmpty {
            showSwipeHint()
        }
    }

    private func showSwipeHint() {
        // 1. Grab the first visible cell
        guard let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? PlantRowCell else { return }
        
        // 2. Animate the "Pull"
        UIView.animate(withDuration: 0.7, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.allowUserInteraction], animations: {
            
            // Slide the white card 60 points to the left to reveal the green and checkmark
            firstCell.mainContainerView.transform = CGAffineTransform(translationX: -60, y: 0)
            firstCell.doneBackgroundView.alpha = 1.0 // Make sure green is visible
            
        }) { _ in
            // 3. Animate the "Snap Back"
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseIn], animations: {
                firstCell.mainContainerView.transform = .identity
                firstCell.doneBackgroundView.alpha = 0 // Hide green again
            }, completion: nil)
        }
    }
    
    
    func loadAndFilterData() {
        guard let url = Bundle.main.url(forResource: "plantData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }

        do {
            let decodedData = try JSONDecoder().decode(PlantData.self, from: data)
            self.filteredPlants = decodedData.plants.filter { plant in
                switch taskType.lowercased() {
                case "watering": return plant.careCycle.watering.lowercased() != "n/a"
                case "pruning": return plant.careCycle.pruning.lowercased() != "n/a"
                case "fertilizing": return plant.careCycle.fertilizing.lowercased() != "n/a"
                default: return true
                }
            }
            collectionView.reloadData()
        } catch {
            print("Error: \(error)")
        }
    }
}
