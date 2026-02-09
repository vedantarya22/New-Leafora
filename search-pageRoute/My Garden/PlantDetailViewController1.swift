import UIKit

class PlantDetailViewController1: UIViewController {
    
    // MARK: - Properties
    var userPlant: UserPlant?
    private var plant: Plant?
    private var collectionView: UICollectionView!
    
    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.95, alpha: 1.0)
        return iv
    }()
    
    private let gradientOverlay: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor]
        gradient.locations = [0.6, 1.0]
        return gradient
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Log Care Activity", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.backgroundColor = UIColor(red: 0.13, green: 0.35, blue: 0.24, alpha: 1.0)
        btn.tintColor = .white
        btn.layer.cornerRadius = 28
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPlantData()
        animateEntrance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientOverlay.frame = heroImageView.bounds
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.98, green: 0.99, blue: 0.98, alpha: 1.0)
        setupHeroImage()
        setupCollectionView()
        setupBackButton()
        setupActionButton()
    }

    private func animateEntrance() {
        heroImageView.alpha = 0
        heroImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut) {
            self.heroImageView.alpha = 1
            self.heroImageView.transform = .identity
        }
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func setupActionButton() {
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    private func loadPlantData() {
        guard let userPlant = userPlant else { return }
        let allPlants = JSONLoader.loadPlants(from: "plantData")
        self.plant = allPlants.first(where: { $0.plantId == userPlant.plantId })
        
        if let imageData = userPlant.imageData {
            heroImageView.image = UIImage(data: imageData)
        } else if let plant = plant {
            heroImageView.image = UIImage(named: plant.imageName)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionTapped() {
        let alert = UIAlertController(title: "Log Care", message: nil, preferredStyle: .actionSheet)
        let tasks = [("💧 Watered", "watering"), ("✂️ Pruned", "pruning"), ("🌱 Fertilized", "fertilizing"), ("🪴 Repotted", "repotting")]
        
        for task in tasks {
            alert.addAction(UIAlertAction(title: task.0, style: .default) { _ in
                self.logCareActivity(type: task.1)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func logCareActivity(type: String) {
        guard var updatedPlant = userPlant else { return }
        let now = Date()
        
        switch type {
        case "watering": updatedPlant.lastWatered = now
        case "pruning": updatedPlant.lastPruned = now
        case "fertilizing": updatedPlant.lastFertilized = now
        case "repotting": updatedPlant.lastRepotted = now
        default: break
        }
        
        self.userPlant = updatedPlant
        PlantStore.shared.updatePlant(updatedPlant)
        collectionView.reloadSections(IndexSet(integer: 1))
    }
}

// MARK: - CollectionView DataSource & Layout
extension PlantDetailViewController1: UICollectionViewDataSource, UICollectionViewDelegate {
    
    private func setupHeroImage() {
        view.addSubview(heroImageView)
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: view.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 420)
        ])
        heroImageView.layer.addSublayer(gradientOverlay)
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never
        
        // Use "CareTaskCell1" for both the XIB name and the ID to avoid confusion
        collectionView.register(UINib(nibName: "CareTaskCell1", bundle: nil), forCellWithReuseIdentifier: "CareTaskCell1")
        collectionView.register(UINib(nibName: "GuideSectionCell", bundle: nil), forCellWithReuseIdentifier: "GuideCell")
        
        view.insertSubview(collectionView, belowSubview: backButton)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIndex, _) in
            if sectionIndex == 0 { return self.createHeaderSection() }
            if sectionIndex == 1 { return self.createCareTasksSection() }
            return self.createGuidesSection()
        }
    }

    private func createHeaderSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(120)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 360, leading: 0, bottom: 20, trailing: 0)
        return section
    }

    private func createCareTasksSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 30, trailing: 20)
        section.interGroupSpacing = 12
        return section
    }

    private func createGuidesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(280), heightDimension: .absolute(180)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 0, leading: 20, bottom: 120, trailing: 20)
        section.interGroupSpacing = 16
        return section
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int { return 3 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 1 ? 4 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            // CAST TO CareTaskCell1 TO ACCESS CONFIGURE
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CareTaskCell1", for: indexPath) as! CareTaskCell1
            guard let p = plant, let up = userPlant else { return cell }
            let tasks: [(String, String, Date?, Int)] = [
                ("💧", "Watering", up.lastWatered, p.careCycle.watering.days),
                ("✂️", "Pruning", up.lastPruned, p.careCycle.pruning.days),
                ("🌱", "Fertilizing", up.lastFertilized, p.careCycle.fertilizing.days),
                ("🪴", "Repotting", up.lastRepotted, p.careCycle.repotting.days)
            ]
            let t = tasks[indexPath.item]
            cell.configure(icon: t.0, taskName: t.1, status: CareCountdown.status(lastDate: t.2, frequencyDays: t.3, taskName: t.1))
            return cell
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "GuideCell", for: indexPath)
    }
}
