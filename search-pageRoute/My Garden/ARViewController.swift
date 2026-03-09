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

    var models: [ModelItem] = []
    var selectedModel: ModelItem?
    var currentAnchor: AnchorEntity?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
            instructionLabel.text = "Select a plant first"
            return
        }
        let loc     = gesture.location(in: arView)
        let results = arView.raycast(from: loc, allowing: .estimatedPlane, alignment: .horizontal)
        guard let first = results.first else {
            instructionLabel.text = "No surface found — move slowly to scan"
            return
        }
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
