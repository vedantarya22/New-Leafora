//
//  ARViewController.swift
//  ARModelViewer
//

import UIKit
import ARKit
import RealityKit

class ARViewController: UIViewController {

    @IBOutlet var arView: ARView!
    @IBOutlet weak var modelCollectionView: UICollectionView!
    @IBOutlet weak var instructionLabel: UILabel!

    @IBOutlet weak var lightMeterPanel: UIView?
    @IBOutlet weak var lightLevelLabel: UILabel?
    @IBOutlet weak var lightStatusIcon: UILabel?
    @IBOutlet weak var lightRecommendationLabel: UILabel?
    @IBOutlet weak var luxValueLabel: UILabel?

    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    
    // Compact Light Meter UI
    private let compactLightPanel = UIView()
    private let compactLightLabel = UILabel()
    private var isLightPanelVisible = false

    var models: [ModelItem] = []
    var selectedModel: ModelItem?
    var currentAnchor: AnchorEntity?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Ensure the old bulky storyboard light meter panel is hidden
        lightMeterPanel?.isHidden          = true
        lightLevelLabel?.isHidden          = true
        lightStatusIcon?.isHidden          = true
        lightRecommendationLabel?.isHidden = true
        luxValueLabel?.isHidden            = true

        loadModels()
        setupARView()
        setupCollectionView()
        setupGestures()
        setupLoadingSpinner()
        setupCompactLightMeter()

        instructionLabel.text = "Select a plant below, then tap a surface to place it"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection       = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }

    // MARK: - AR Setup

    func setupARView() {
        arView.automaticallyConfigureSession = false
        arView.session.delegate = self // Listen for light estimation
        let coaching = ARCoachingOverlayView()
        coaching.session                = arView.session
        coaching.autoresizingMask       = [.flexibleWidth, .flexibleHeight]
        coaching.goal                   = .horizontalPlane
        coaching.activatesAutomatically = true
        arView.addSubview(coaching)
    }

    // MARK: - Loading Spinner

    func setupLoadingSpinner() {
        loadingSpinner.color            = .white
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.backgroundColor    = UIColor.black.withAlphaComponent(0.6)
        container.layer.cornerRadius = 16
        container.clipsToBounds      = true
        container.isHidden           = true
        container.tag                = 9001
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(loadingSpinner)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 80),
            container.heightAnchor.constraint(equalToConstant: 80),
            loadingSpinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            loadingSpinner.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }

    private func showLoadingSpinner(_ visible: Bool) {
        view.viewWithTag(9001)?.isHidden = !visible
        visible ? loadingSpinner.startAnimating() : loadingSpinner.stopAnimating()
    }

    // MARK: - Compact Light Meter

    private func setupCompactLightMeter() {
        // Toggle Button in Navigation Bar
        let toggleButton = UIBarButtonItem(image: UIImage(systemName: "sun.max.fill"), style: .plain, target: self, action: #selector(toggleLightMeter))
        toggleButton.tintColor = .label
        navigationItem.rightBarButtonItem = toggleButton
        
        // Compact Panel
        compactLightPanel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        compactLightPanel.layer.cornerRadius = 16
        compactLightPanel.translatesAutoresizingMaskIntoConstraints = false
        compactLightPanel.alpha = 0 // Hidden by default
        view.addSubview(compactLightPanel)
        
        // Label inside panel
        compactLightLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        compactLightLabel.textColor = .white
        compactLightLabel.textAlignment = .center
        compactLightLabel.translatesAutoresizingMaskIntoConstraints = false
        compactLightPanel.addSubview(compactLightLabel)
        
        NSLayoutConstraint.activate([
            // Panel constraints (snug up into the navigation bar area right underneath the button)
            compactLightPanel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -12),
            compactLightPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            compactLightPanel.heightAnchor.constraint(equalToConstant: 32),
            
            compactLightLabel.leadingAnchor.constraint(equalTo: compactLightPanel.leadingAnchor, constant: 12),
            compactLightLabel.trailingAnchor.constraint(equalTo: compactLightPanel.trailingAnchor, constant: -12),
            compactLightLabel.centerYAnchor.constraint(equalTo: compactLightPanel.centerYAnchor)
        ])
    }
    
    @objc private func toggleLightMeter() {
        isLightPanelVisible.toggle()
        
        // Update the sun icon color
        navigationItem.rightBarButtonItem?.tintColor = isLightPanelVisible ? .systemBlue : .label
        
        UIView.animate(withDuration: 0.3) {
            self.compactLightPanel.alpha = self.isLightPanelVisible ? 1.0 : 0.0
        }
    }

    // MARK: - Collection View

    func setupCollectionView() {
        modelCollectionView.delegate        = self
        modelCollectionView.dataSource      = self
        modelCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        modelCollectionView.register(ModelCell.self, forCellWithReuseIdentifier: "ModelCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection         = .horizontal
        layout.itemSize                = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing      = 10
        layout.sectionInset            = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        modelCollectionView.collectionViewLayout = layout
    }

    // MARK: - Models

    func loadModels() {
        models = [
            ModelItem(name: "Monstera",       fileName: "temp",    thumbnail: "🌿"),
            ModelItem(name: "Fiddle Leaf Fig", fileName: "krishna", thumbnail: "🌱"),
            ModelItem(name: "Snake Plant",     fileName: "krishna2",thumbnail: "🪴"),
        ]
    }

    // MARK: - Gestures

    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let model = selectedModel else {
            instructionLabel.alpha = 1
            instructionLabel.text = "Select a plant first"
            return
        }
        let loc     = gesture.location(in: arView)
        let results = arView.raycast(from: loc, allowing: .estimatedPlane, alignment: .horizontal)
        guard let first = results.first else {
            if currentAnchor == nil {
                instructionLabel.alpha = 1
                instructionLabel.text = "No surface found — move slowly to scan"
            }
            return
        }
        instructionLabel.alpha = 1
        placeModel(model, at: first)
    }

    // MARK: - Place Model

    func placeModel(_ model: ModelItem, at result: ARRaycastResult) {
        if let old = currentAnchor { arView.scene.removeAnchor(old) }
        currentAnchor = nil

        let anchor = AnchorEntity(world: result.worldTransform)
        arView.scene.addAnchor(anchor)
        currentAnchor = anchor

        showLoadingSpinner(true)
        instructionLabel.text = "Placing \(model.name)…"

        Task { [weak self] in
            guard let self else { return }
            do {
                let entity = try await ModelEntity(named: model.fileName)
                await MainActor.run {
                    self.showLoadingSpinner(false)
                    let ext    = entity.model?.mesh.bounds.extents ?? .one
                    let maxDim = max(ext.x, ext.y, ext.z)
                    entity.scale = SIMD3<Float>(repeating: maxDim > 0 ? 0.4 / maxDim : 1.0)
                    entity.generateCollisionShapes(recursive: true)
                    anchor.addChild(entity)
                    self.arView.installGestures([.translation, .rotation, .scale], for: entity)
                    self.instructionLabel.text = "\(model.name) placed!"
                    
                    // Hide the instruction dialogue box after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        UIView.animate(withDuration: 0.5) {
                            self.instructionLabel.alpha = 0
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.showLoadingSpinner(false)
                    self.instructionLabel.text = "Could not load model"
                    self.arView.scene.removeAnchor(anchor)
                    self.currentAnchor = nil
                }
            }
        }
    }
}

// MARK: - UICollectionView

extension ARViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelCell", for: indexPath) as! ModelCell
        let model = models[indexPath.item]
        cell.configure(with: model)
        cell.isSelectedCell = (selectedModel?.fileName == model.fileName)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedModel = models[indexPath.item]
        collectionView.reloadData()
        instructionLabel.alpha = 1
        instructionLabel.text = "Tap a surface to place \(models[indexPath.item].name)"
    }
}

// MARK: - Data Model

struct ModelItem {
    let name: String
    let fileName: String
    let thumbnail: String
    
}

// MARK: - ModelCell

class ModelCell: UICollectionViewCell {

    private let thumbnailLabel = UILabel()
    private let nameLabel      = UILabel()
    var isSelectedCell: Bool = false { didSet { updateSelection() } }

    override init(frame: CGRect)   { super.init(frame: frame);  setupUI() }
    required init?(coder: NSCoder) { super.init(coder: coder);  setupUI() }

    private func setupUI() {
        backgroundColor    = .darkGray
        layer.cornerRadius = 10
        layer.borderWidth  = 2
        layer.borderColor  = UIColor.clear.cgColor

        thumbnailLabel.font          = .systemFont(ofSize: 28)
        thumbnailLabel.textAlignment = .center
        thumbnailLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font          = .systemFont(ofSize: 10)
        nameLabel.textAlignment = .center
        nameLabel.textColor     = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumbnailLabel)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            thumbnailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: thumbnailLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
        ])
    }

    func configure(with model: ModelItem) {
        thumbnailLabel.text = model.thumbnail
        nameLabel.text      = model.name
    }

    private func updateSelection() {
        layer.borderColor = isSelectedCell
            ? UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1).cgColor
            : UIColor.clear.cgColor
        backgroundColor = isSelectedCell
            ? UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 0.35)
            : .darkGray
    }
}

// MARK: - ARSessionDelegate for Light Meter

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let lightEstimate = frame.lightEstimate else { return }
        
        let intensity = lightEstimate.ambientIntensity
        
        // Intensity is typically 1000 for neutral. We map this roughly for user feel.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Artificial lux calculation just to show users numbers changing
            let estimatedLux = Int(intensity / 3.0) 
            self.luxValueLabel?.text = "\(estimatedLux) Lux"
            
            if intensity < 300 {
                self.compactLightLabel.text = "🌙 Too Dark"
                self.compactLightLabel.textColor = .systemOrange
            } else if intensity >= 300 && intensity < 800 {
                self.compactLightLabel.text = "🌤 Acceptable"
                self.compactLightLabel.textColor = .systemYellow
            } else if intensity >= 800 && intensity <= 2000 {
                self.compactLightLabel.text = "✨ Perfect Light"
                self.compactLightLabel.textColor = .systemGreen
            } else {
                self.compactLightLabel.text = "☀️ Too Bright"
                self.compactLightLabel.textColor = .systemRed
            }
        }
    }
}
