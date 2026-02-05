import UIKit

class PlantListViewController: UIViewController,
                               UICollectionViewDataSource,
                               UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var taskType: String = ""
    var filteredPlants: [UserPlant] = []
    var allPlants: [Plant] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = taskType

        // Register Cell XIB
        let nib = UINib(nibName: "PlantRowCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PlantRowCell")

        collectionView.dataSource = self
        collectionView.delegate = self


        allPlants = JSONLoader.loadPlants(from: "plantData")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAndFilterData()
    }

    
    

    // MARK: - Collection Layout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.frame.width, height: 90)
    }

    // MARK: - DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        return filteredPlants.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PlantRowCell",
            for: indexPath
        ) as! PlantRowCell

        // ✅ Get correct UserPlant
        let userPlant = filteredPlants[indexPath.row]

        // ✅ Configure cell
        cell.configure(
              with: userPlant,
              task: taskType,
              allPlants: allPlants
          )


        // ✅ Swipe Done Closure
        cell.onDone = { [weak self, weak cell] in
            guard let self = self,
                  let currentCell = cell,
                  let currentIndexPath = self.collectionView.indexPath(for: currentCell)
            else { return }

            let completedPlant = self.filteredPlants[currentIndexPath.row]

            // ✅ Mark task completed in PlantStore
            self.markTaskDone(for: completedPlant)

            // ✅ Remove from list instantly
            self.filteredPlants.remove(at: currentIndexPath.row)

            // ✅ Animate deletion
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [currentIndexPath])
            })
        }

        return cell
    }

    // MARK: - Swipe Hint Animation

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !filteredPlants.isEmpty {
            showSwipeHint()
        }
    }

    private func showSwipeHint() {

        guard let firstCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
        ) as? PlantRowCell else { return }

        UIView.animate(
            withDuration: 0.7,
            delay: 0.5,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction],
            animations: {

                firstCell.mainContainerView.transform =
                    CGAffineTransform(translationX: -60, y: 0)

                firstCell.doneBackgroundView.alpha = 1.0

            }) { _ in

            UIView.animate(withDuration: 0.5,
                           delay: 0.2,
                           options: [.curveEaseIn],
                           animations: {

                firstCell.mainContainerView.transform = .identity
                firstCell.doneBackgroundView.alpha = 0

            })
        }
    }

    // MARK: - Task Completion

    func markTaskDone(for userPlant: UserPlant) {
        PlantStore.shared.markTaskDone(
            userPlantID: userPlant.id,
            taskType: taskType
        )
    }

    // MARK: - Load + Filter Pending Plants

    func loadAndFilterData() {
           // ✅ Get ALL individual plants (no grouping)
           let allUserPlants = PlantStore.shared.allPlants()

           // ✅ Filter plants that have tasks due
           filteredPlants = allUserPlants.filter { userPlant in
               let isDue: Bool

               switch taskType.lowercased() {
               case "watering":
                   isDue = TaskDueEngine.isDue(userPlant, task: .watering)

               case "pruning":
                   isDue = TaskDueEngine.isDue(userPlant, task: .pruning)

               case "fertilizing":
                   isDue = TaskDueEngine.isDue(userPlant, task: .fertilizing)

               case "repotting":
                   isDue = TaskDueEngine.isDue(userPlant, task: .repotting)

               default:
                   isDue = true
               }

               return isDue
           }

           print("✅ Filtered \(filteredPlants.count) plants needing \(taskType)")
           collectionView.reloadData()
       }


}
