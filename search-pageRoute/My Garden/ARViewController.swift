//
//  ARViewController.swift
//  ARModelViewer
//
//  Refined: multi-placement, long-press remove, placement counter,
//  fixed layout, compact light meter, clear-all button.
//

import UIKit
import ARKit
import RealityKit

// MARK: - Data Model

struct ModelItem {
    let name: String
    let fileName: String
    let thumbnail: String
    let image: String?
}

// MARK: - Placed Plant Record

private struct PlacedPlant {
    let anchor: AnchorEntity
    let entity: ModelEntity
    let modelName: String
}

// MARK: - ARViewController

class ARViewController: UIViewController {

    // ── Storyboard outlets ──────────────────────────────────────────────────
    @IBOutlet var arView: ARView!
    @IBOutlet weak var modelCollectionView: UICollectionView!
    @IBOutlet weak var instructionLabel: UILabel!

    // Legacy storyboard light-meter outlets (kept to avoid IB errors, always hidden)
    @IBOutlet weak var lightMeterPanel: UIView?
    @IBOutlet weak var lightLevelLabel: UILabel?
    @IBOutlet weak var lightStatusIcon: UILabel?
    @IBOutlet weak var lightRecommendationLabel: UILabel?
    @IBOutlet weak var luxValueLabel: UILabel?

    // ── Private state ────────────────────────────────────────────────────────
    private var models: [ModelItem] = []
    private var selectedModel: ModelItem?
    
    /// Pass a plant name here to auto-select its corresponding AR model
    var targetPlantName: String?

    /// All currently placed plants — supports unlimited multi-placement.
    private var placedPlants: [PlacedPlant] = []

    /// Running total for the placement counter badge.
    private var placementCount: Int = 0 {
        didSet { updatePlacementBadge() }
    }

    //  Loading spinner
    private let loadingSpinner    = UIActivityIndicatorView(style: .large)
    private let spinnerContainer  = UIView()

    //  Compact light meter
    private let compactLightPanel = UIView()
    private let compactLightLabel = UILabel()
    private var isLightPanelVisible = false

    // Placement badge
    private let placementBadge      = UIView()
    private let placementBadgeLabel = UILabel()

    // Instruction auto-hide timer
    private var instructionHideTimer: DispatchWorkItem?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide legacy storyboard light-meter widgets
        [lightMeterPanel, lightLevelLabel,
         lightStatusIcon, lightRecommendationLabel,
         luxValueLabel].forEach { $0?.isHidden = true }

        loadModels()
        setupARView()
        setupCollectionView()
        setupGestures()
        setupLoadingSpinner()
        setupCompactLightMeter()
        setupNavigationBar()
        setupPlacementBadge()

        setupPlacementBadge()

        if let target = targetPlantName, let match = models.first(where: { $0.name.lowercased() == target.lowercased() || target.lowercased().contains($0.name.lowercased()) }) {
            selectedModel = match
            showInstruction("Tap a surface to place \(match.name)")
        } else {
            selectedModel = models.first
            showInstruction("Select a plant below, then tap a surface to place it")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config                      = ARWorldTrackingConfiguration()
        config.planeDetection           = [.horizontal]
        config.environmentTexturing     = .automatic
        arView.session.run(config)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    // MARK: - AR Setup

    private func setupARView() {
        arView.automaticallyConfigureSession = false
        arView.session.delegate = self

        let coaching                    = ARCoachingOverlayView()
        coaching.session                = arView.session
        coaching.goal                   = .horizontalPlane
        coaching.activatesAutomatically = true
        arView.addSubview(coaching)
        
        coaching.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coaching.topAnchor.constraint(equalTo: arView.topAnchor),
            coaching.bottomAnchor.constraint(equalTo: arView.bottomAnchor),
            coaching.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
            coaching.trailingAnchor.constraint(equalTo: arView.trailingAnchor)
        ])
    }

    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        // Right: sun toggle
        let sunButton = UIBarButtonItem(
            image: UIImage(systemName: "sun.max.fill"),
            style: .plain,
            target: self,
            action: #selector(toggleLightMeter)
        )
        sunButton.tintColor = .label

        // Left: back chevron
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        backButton.tintColor = .label

        // Left: trash (clear all)
        let trashButton = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearAllPlants)
        )
        trashButton.tintColor = .systemRed

        navigationItem.rightBarButtonItem = sunButton
        navigationItem.leftBarButtonItems = [backButton, trashButton]
    }

    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }


    // MARK: - Loading Spinner

    private func setupLoadingSpinner() {
        loadingSpinner.color            = .white
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false

        spinnerContainer.backgroundColor    = UIColor.black.withAlphaComponent(0.65)
        spinnerContainer.layer.cornerRadius = 16
        spinnerContainer.clipsToBounds      = true
        spinnerContainer.isHidden           = true
        spinnerContainer.translatesAutoresizingMaskIntoConstraints = false
        spinnerContainer.addSubview(loadingSpinner)
        view.addSubview(spinnerContainer)

        NSLayoutConstraint.activate([
            spinnerContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerContainer.widthAnchor.constraint(equalToConstant: 80),
            spinnerContainer.heightAnchor.constraint(equalToConstant: 80),
            loadingSpinner.centerXAnchor.constraint(equalTo: spinnerContainer.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: spinnerContainer.centerYAnchor),
        ])
    }

    private func showLoadingSpinner(_ visible: Bool) {
        spinnerContainer.isHidden = !visible
        visible ? loadingSpinner.startAnimating() : loadingSpinner.stopAnimating()
    }

    // MARK: - Compact Light Meter

    private func setupCompactLightMeter() {
        compactLightPanel.backgroundColor    = UIColor.black.withAlphaComponent(0.65)
        compactLightPanel.layer.cornerRadius = 14
        compactLightPanel.alpha              = 0
        compactLightPanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(compactLightPanel)

        compactLightLabel.font          = .systemFont(ofSize: 13, weight: .semibold)
        compactLightLabel.textColor     = .white
        compactLightLabel.textAlignment = .center
        compactLightLabel.translatesAutoresizingMaskIntoConstraints = false
        compactLightPanel.addSubview(compactLightLabel)

        NSLayoutConstraint.activate([
            // Position directly below the safe-area top (under nav bar)
            compactLightPanel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            compactLightPanel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -16),
            compactLightPanel.heightAnchor.constraint(equalToConstant: 30),

            compactLightLabel.leadingAnchor.constraint(
                equalTo: compactLightPanel.leadingAnchor, constant: 10),
            compactLightLabel.trailingAnchor.constraint(
                equalTo: compactLightPanel.trailingAnchor, constant: -10),
            compactLightLabel.centerYAnchor.constraint(
                equalTo: compactLightPanel.centerYAnchor),
        ])
    }

    @objc private func toggleLightMeter() {
        isLightPanelVisible.toggle()
        navigationItem.rightBarButtonItem?.tintColor = isLightPanelVisible ? .systemBlue : .label

        UIView.animate(withDuration: 0.25) {
            self.compactLightPanel.alpha = self.isLightPanelVisible ? 1.0 : 0.0
        }
    }

    // MARK: - Placement Badge

    private func setupPlacementBadge() {
        placementBadge.backgroundColor    = UIColor.systemGreen.withAlphaComponent(0.85)
        placementBadge.layer.cornerRadius = 14
        placementBadge.isHidden           = true
        placementBadge.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placementBadge)

        placementBadgeLabel.font          = .systemFont(ofSize: 13, weight: .bold)
        placementBadgeLabel.textColor     = .white
        placementBadgeLabel.textAlignment = .center
        placementBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        placementBadge.addSubview(placementBadgeLabel)

        NSLayoutConstraint.activate([
            placementBadge.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            placementBadge.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 16),
            placementBadge.heightAnchor.constraint(equalToConstant: 30),
            placementBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),

            placementBadgeLabel.leadingAnchor.constraint(
                equalTo: placementBadge.leadingAnchor, constant: 10),
            placementBadgeLabel.trailingAnchor.constraint(
                equalTo: placementBadge.trailingAnchor, constant: -10),
            placementBadgeLabel.centerYAnchor.constraint(
                equalTo: placementBadge.centerYAnchor),
        ])
    }

    private func updatePlacementBadge() {
        if placementCount == 0 {
            placementBadge.isHidden = true
        } else {
            placementBadge.isHidden = false
            placementBadgeLabel.text = "🌱 \(placementCount) placed"
        }
    }

    // MARK: - Collection View

    private func setupCollectionView() {
        modelCollectionView.delegate        = self
        modelCollectionView.dataSource      = self
        modelCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        modelCollectionView.register(ModelCell.self, forCellWithReuseIdentifier: "ModelCell")

        let layout                       = UICollectionViewFlowLayout()
        layout.scrollDirection           = .horizontal
        layout.itemSize                  = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing   = 10
        layout.minimumLineSpacing        = 10
        layout.sectionInset              = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        modelCollectionView.collectionViewLayout = layout
    }

    // MARK: - Models

    private func loadModels() {
        models = [
            // Newly added 7 models mapped to their real plant names
            ModelItem(name: "Chinese Money Plant", fileName: "chinese_moneyplant", thumbnail: "🌿", image: nil),
            ModelItem(name: "Rose",           fileName: "crimson_roses", thumbnail: "🌹", image: nil),
            ModelItem(name: "Lemongrass",     fileName: "lemongrass", thumbnail: "🌾", image: nil),
            ModelItem(name: "Marigold",       fileName: "marigold", thumbnail: "🌼", image: nil),
            ModelItem(name: "Portulaca",      fileName: "portulaca", thumbnail: "🌸", image: nil),
            ModelItem(name: "Tulsi",          fileName: "tulsi", thumbnail: "🌱", image: nil),
            ModelItem(name: "Jasmine",        fileName: "white_jasmine", thumbnail: "🏵", image: nil),
            ModelItem(name: "Monstera",       fileName: "monstera", thumbnail: "🌿", image: nil)
            
            

        ]
    }

    // MARK: - Gestures

    private func setupGestures() {
        // Single tap → place plant
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)

        // Long press → remove the tapped plant
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.6
        arView.addGestureRecognizer(longPress)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let model = selectedModel else {
            showInstruction("Select a plant first ☝️")
            return
        }
        let loc     = gesture.location(in: arView)
        let results = arView.raycast(from: loc, allowing: .estimatedPlane, alignment: .horizontal)
        guard let first = results.first else {
            showInstruction("No surface found — move slowly to scan")
            return
        }
        placeModel(model, at: first)
    }

    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let loc = gesture.location(in: arView)

        // Hit-test against placed entities
        if let hit = arView.entity(at: loc) {
            // Walk up to find the root entity that belongs to a PlacedPlant
            removePlantContaining(entity: hit)
        }
    }

    // MARK: - Place Model (multi-placement)

    private func placeModel(_ model: ModelItem, at result: ARRaycastResult) {
        let anchor = AnchorEntity(world: result.worldTransform)
        arView.scene.addAnchor(anchor)

        showLoadingSpinner(true)
        showInstruction("Placing \(model.name)…")

        Task { [weak self] in
            guard let self else { return }
            do {
                let entity = try await ModelEntity(named: model.fileName)
                await MainActor.run {
                    self.showLoadingSpinner(false)

                    // Auto-scale to a consistent ~40 cm height
                    let ext    = entity.model?.mesh.bounds.extents ?? .one
                    let maxDim = max(ext.x, ext.y, ext.z)
                    entity.scale = SIMD3<Float>(repeating: maxDim > 0 ? 0.4 / maxDim : 1.0)

                    entity.generateCollisionShapes(recursive: true)
                    anchor.addChild(entity)
                    self.arView.installGestures([.translation, .rotation, .scale], for: entity)

                    // Track it
                    let placed = PlacedPlant(anchor: anchor, entity: entity, modelName: model.name)
                    self.placedPlants.append(placed)
                    self.placementCount += 1

                    self.showInstruction("\(model.name) placed! Long-press any plant to remove it.", autohide: 3)
                }
            } catch {
                await MainActor.run {
                    self.showLoadingSpinner(false)
                    self.arView.scene.removeAnchor(anchor)
                    self.showInstruction("Could not load '\(model.name)' model")
                }
            }
        }
    }

    // MARK: - Remove Individual Plant

    private func removePlantContaining(entity: Entity) {
        // Find the PlacedPlant whose anchor tree contains this entity
        guard let idx = placedPlants.firstIndex(where: { plant in
            var current: Entity? = entity
            while let e = current {
                if e === plant.entity { return true }
                current = e.parent
            }
            return false
        }) else { return }

        let plant = placedPlants[idx]

        let alert = UIAlertController(
            title: "Remove \(plant.modelName)?",
            message: nil,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.arView.scene.removeAnchor(plant.anchor)
            self.placedPlants.remove(at: idx)
            self.placementCount -= 1
            self.showInstruction("\(plant.modelName) removed", autohide: 2)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Clear All Plants

    @objc private func clearAllPlants() {
        guard !placedPlants.isEmpty else {
            showInstruction("No plants placed yet", autohide: 2)
            return
        }

        let alert = UIAlertController(
            title: "Clear All Plants",
            message: "Remove all \(placedPlants.count) placed plant(s)?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.placedPlants.forEach { self.arView.scene.removeAnchor($0.anchor) }
            self.placedPlants.removeAll()
            self.placementCount = 0
            self.showInstruction("All plants removed", autohide: 2)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Instruction Label Helper

    private func showInstruction(_ text: String, autohide seconds: Double? = nil) {
        instructionHideTimer?.cancel()
        instructionHideTimer = nil

        instructionLabel.alpha = 1
        instructionLabel.text  = text

        if let delay = seconds {
            let work = DispatchWorkItem { [weak self] in
                UIView.animate(withDuration: 0.5) { self?.instructionLabel.alpha = 0 }
            }
            instructionHideTimer = work
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        }
    }
}

// MARK: - UICollectionView

extension ARViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int { models.count }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ModelCell", for: indexPath) as! ModelCell
        let model = models[indexPath.item]
        cell.configure(with: model)
        cell.isSelectedCell = (selectedModel?.fileName == model.fileName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectedModel = models[indexPath.item]
        collectionView.reloadData()
        showInstruction("Tap a surface to place \(models[indexPath.item].name)")
    }
}

// MARK: - ModelCell

class ModelCell: UICollectionViewCell {

    private let thumbnailLabel = UILabel()
    private let thumbnailImage = UIImageView()
    private let nameLabel      = UILabel()

    var isSelectedCell: Bool = false { didSet { updateSelection() } }

    override init(frame: CGRect)   { super.init(frame: frame);  setupUI() }
    required init?(coder: NSCoder) { super.init(coder: coder);  setupUI() }

    private func setupUI() {
        backgroundColor    = .darkGray
        layer.cornerRadius = 10
        layer.borderWidth  = 2
        layer.borderColor  = UIColor.clear.cgColor

        // Emoji thumbnail
        thumbnailLabel.font          = .systemFont(ofSize: 28)
        thumbnailLabel.textAlignment = .center
        thumbnailLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailLabel)

        // Image thumbnail (shown when image asset exists)
        thumbnailImage.contentMode        = .scaleAspectFill
        thumbnailImage.layer.cornerRadius = 6
        thumbnailImage.clipsToBounds      = true
        thumbnailImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnailImage)

        // Name label
        nameLabel.font          = .systemFont(ofSize: 10, weight: .medium)
        nameLabel.textColor     = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            // Image fills top portion
            thumbnailImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            thumbnailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            thumbnailImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            thumbnailImage.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -4),

            // Emoji centered in same region
            thumbnailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            thumbnailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -4),

            // Name always at the bottom
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            nameLabel.heightAnchor.constraint(equalToConstant: 14),
        ])
    }

    func configure(with model: ModelItem) {
        if let name = model.image, let img = UIImage(named: name) {
            thumbnailImage.image    = img
            thumbnailImage.isHidden = false
            thumbnailLabel.isHidden = true
        } else {
            thumbnailImage.isHidden = true
            thumbnailLabel.isHidden = false
            thumbnailLabel.text     = model.thumbnail
        }
        nameLabel.text = model.name
    }

    private func updateSelection() {
        let green = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1)
        layer.borderColor = isSelectedCell ? green.cgColor : UIColor.clear.cgColor
        backgroundColor   = isSelectedCell
            ? UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 0.35)
            : .darkGray
    }
}

// MARK: - ARSessionDelegate  (Light Meter)

extension ARViewController: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let estimate = frame.lightEstimate else { return }
        let intensity = estimate.ambientIntensity

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard self.isLightPanelVisible else { return }

            switch intensity {
            case ..<300:
                self.compactLightLabel.text      = "🌙 Too Dark"
                self.compactLightLabel.textColor = .systemOrange
            case 300..<800:
                self.compactLightLabel.text      = "🌤 Low Light"
                self.compactLightLabel.textColor = .systemYellow
            case 800...2000:
                self.compactLightLabel.text      = "✨ Perfect Light"
                self.compactLightLabel.textColor = .systemGreen
            default:
                self.compactLightLabel.text      = "☀️ Too Bright"
                self.compactLightLabel.textColor = .systemRed
            }
        }
    }
}
