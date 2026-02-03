import UIKit

class PlantListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var taskType: String = ""
    var filteredPlants: [Plant] = []
    var themeColor: UIColor = .black

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = taskType
        
        // 1. Register the XIB
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadAndFilterData()
    }

    // Direct color update every time the view is about to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure Large Titles are enabled for this screen
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // APPLY THE COLOR
        let navBar = navigationController?.navigationBar
        navBar?.tintColor = themeColor // Back button color
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Makes it look cleaner
        appearance.largeTitleTextAttributes = [.foregroundColor: themeColor]
        appearance.titleTextAttributes = [.foregroundColor: themeColor]
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    // MARK: - Data Source & Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Full width minus some padding for a "card" feel if you prefer
        return CGSize(width: collectionView.frame.width, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredPlants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantRowCell", for: indexPath) as! PlantRowCell
        let plant = filteredPlants[indexPath.row]
        
        cell.configure(with: plant, task: taskType)
        
        cell.onDone = { [weak self, weak cell] in
            guard let self = self, let currentCell = cell else { return }
            guard let currentIndexPath = self.collectionView.indexPath(for: currentCell) else { return }
            
            if currentIndexPath.row < self.filteredPlants.count {
                self.filteredPlants.remove(at: currentIndexPath.row)
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [currentIndexPath])
                }, completion: { _ in
                    // Optional: Update title or subheader here if count changes
                })
            }
        }
        return cell
    }
    
    // MARK: - Animation Hint
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !filteredPlants.isEmpty {
            showSwipeHint()
        }
    }

    private func showSwipeHint() {
        guard let firstCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? PlantRowCell else { return }
        
        UIView.animate(withDuration: 0.7, delay: 0.5, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [.allowUserInteraction], animations: {
            firstCell.mainContainerView.transform = CGAffineTransform(translationX: -60, y: 0)
            firstCell.doneBackgroundView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseIn], animations: {
                firstCell.mainContainerView.transform = .identity
                firstCell.doneBackgroundView.alpha = 0
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
