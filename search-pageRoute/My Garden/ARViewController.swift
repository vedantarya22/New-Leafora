//
//  PlantARViewController.swift
//  ARModelViewer
//
//  Created on 2026
//

import UIKit
import ARKit
import RealityKit
import AVFoundation

class ARViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var arView: ARView!
    @IBOutlet weak var modelCollectionView: UICollectionView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var lightMeterPanel: UIView!
    @IBOutlet weak var lightLevelLabel: UILabel!
    @IBOutlet weak var lightStatusIcon: UILabel!
    @IBOutlet weak var lightRecommendationLabel: UILabel!
    @IBOutlet weak var luxValueLabel: UILabel!
    
    // MARK: - Show Info Button
    private let showInfoButton = UIButton(type: .system)
    
    // MARK: - Properties
    var models: [ModelItem] = []
    var selectedModel: ModelItem?
    var currentModelEntity: ModelEntity?
    var currentAnchor: AnchorEntity?
    var lightMeterTimer: Timer?
    var currentLightLevel: Float = 0.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lightMeterPanel.isHidden = true
        
        setupARView()
        setupCollectionView()
        loadModels()
        setupGestures()
        setupShowInfoButton()
        
        instructionLabel.text = "Select a plant below and tap to place it"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
    
    // MARK: - Setup
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
    }
    
    func setupCollectionView() {
        modelCollectionView.delegate = self
        modelCollectionView.dataSource = self
        modelCollectionView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        modelCollectionView.register(ModelCell.self, forCellWithReuseIdentifier: "ModelCell")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        modelCollectionView.collectionViewLayout = layout
    }
    
    func setupShowInfoButton() {
        showInfoButton.setTitle("🌿  Show Plant Info", for: .normal)
        showInfoButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        showInfoButton.setTitleColor(.white, for: .normal)
        showInfoButton.backgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        showInfoButton.layer.cornerRadius = 20
        showInfoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        showInfoButton.layer.shadowColor = UIColor.black.cgColor
        showInfoButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        showInfoButton.layer.shadowRadius = 8
        showInfoButton.layer.shadowOpacity = 0.25
        showInfoButton.isHidden = true  // Hidden until a model is placed
        showInfoButton.translatesAutoresizingMaskIntoConstraints = false
        showInfoButton.addTarget(self, action: #selector(showInfoTapped), for: .touchUpInside)
        
        // Add to main view, centered, just above the collection view
        view.addSubview(showInfoButton)
        NSLayoutConstraint.activate([
            showInfoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showInfoButton.bottomAnchor.constraint(equalTo: modelCollectionView.topAnchor, constant: -12),
        ])
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    func loadModels() {
        models = [
            ModelItem(
                name: "Monstera Plant",
                fileName: "sset",
                thumbnail: "🌿",
                LightNeed: LightNeed(
                    plantName: "Monstera Deliciosa",
                    minLux: 1000,
                    optimalMinLux: 1500,
                    optimalMaxLux: 2500,
                    maxLux: 3000,
                    lowLightMessage: "Too dark! Monstera needs bright indirect light.",
                    optimalMessage: "Perfect! This lighting is ideal for Monstera.",
                    highLightMessage: "Too bright! Direct sunlight can burn the leaves.",
                    description: "Thrives in bright, indirect light. Tolerates some shade."
                ),
                plantInfo: PlantInfo(
                    commonName: "Monstera",
                    scientificName: "Monstera deliciosa",
                    description: "Monstera is a tropical plant famous for its dramatic split leaves. It grows quickly in bright indirect light and is one of the most popular houseplants worldwide.",
                    careLevel: "Easy",
                    wateringFrequency: "Every 1–2 weeks",
                    sunlight: "Bright indirect light",
                    pruningSteps: [
                        PruningStep(title: "Gather your tools", detail: "Get clean, sharp pruning shears or scissors. Wipe them with rubbing alcohol to prevent spreading disease.", sfSymbol: "scissors"),
                        PruningStep(title: "Identify dead leaves", detail: "Look for yellow, brown, or damaged leaves. These should be removed first to redirect energy to healthy growth.", sfSymbol: "eye"),
                        PruningStep(title: "Cut at the base", detail: "Cut the stem as close to the main trunk as possible at a 45° angle. Never leave stubs — they invite rot.", sfSymbol: "arrow.down.to.line"),
                        PruningStep(title: "Trim large leaves", detail: "For oversized leaves, cut just above a node (the bump where a leaf meets the stem) to encourage new branching.", sfSymbol: "leaf"),
                        PruningStep(title: "Clean up & aftercare", detail: "Wipe the cut with cinnamon powder (natural antifungal) and keep out of direct sun for a week while it recovers.", sfSymbol: "sparkles"),
                    ]
                )
            ),
            ModelItem(
                name: "Fiddle Leaf Fig",
                fileName: "krishna",
                thumbnail: "🌱",
                LightNeed: LightNeed(
                    plantName: "Fiddle Leaf Fig",
                    minLux: 1500,
                    optimalMinLux: 2000,
                    optimalMaxLux: 3500,
                    maxLux: 4000,
                    lowLightMessage: "Not enough light! Fiddle Leaf Fig needs bright light.",
                    optimalMessage: "Excellent! Perfect bright indirect light for your Fiddle Leaf Fig.",
                    highLightMessage: "Too much direct sun! May cause leaf burn.",
                    description: "Loves bright, filtered light. Needs more light than most plants."
                ),
                plantInfo: PlantInfo(
                    commonName: "Fiddle Leaf Fig",
                    scientificName: "Ficus lyrata",
                    description: "The Fiddle Leaf Fig is a striking indoor tree with large, violin-shaped leaves. It is a statement plant that loves consistency — it dislikes being moved.",
                    careLevel: "Moderate",
                    wateringFrequency: "Every 7–10 days",
                    sunlight: "Bright indirect to direct light",
                    pruningSteps: [
                        PruningStep(title: "Choose the right season", detail: "Prune in spring or early summer during active growth. Avoid pruning in winter when the plant is dormant.", sfSymbol: "calendar"),
                        PruningStep(title: "Sterilise your tools", detail: "Use sharp pruning shears cleaned with 70% isopropyl alcohol to make clean cuts and prevent infection.", sfSymbol: "scissors"),
                        PruningStep(title: "Remove problem leaves", detail: "Start by cutting any brown-spotted, torn, or yellow leaves at the base of their stem near the trunk.", sfSymbol: "minus.circle"),
                        PruningStep(title: "Shape the canopy", detail: "To encourage a bushier shape, cut the top stem just above a node. New branches will sprout from below the cut.", sfSymbol: "leaf.arrow.triangle.circlepath"),
                        PruningStep(title: "Control the sap", detail: "Fiddle Leaf Fig bleeds milky sap when cut. Wear gloves and dab cuts with a cloth. The sap can irritate skin.", sfSymbol: "drop"),
                        PruningStep(title: "Recovery care", detail: "Place in consistent bright indirect light and do not repot for 4–6 weeks after pruning to reduce stress.", sfSymbol: "sun.max"),
                    ]
                )
            ),
            ModelItem(
                name: "Snake Plant",
                fileName: "krishna2",
                thumbnail: "🪴",
                LightNeed: LightNeed(
                    plantName: "Snake Plant",
                    minLux: 500,
                    optimalMinLux: 800,
                    optimalMaxLux: 2000,
                    maxLux: 3500,
                    lowLightMessage: "Low light detected. Snake plant tolerates this but grows slowly.",
                    optimalMessage: "Great spot! Snake plant will thrive here.",
                    highLightMessage: "Very bright! Snake plant tolerates this but prefers indirect light.",
                    description: "Very adaptable! Tolerates low light but prefers indirect bright light."
                ),
                plantInfo: PlantInfo(
                    commonName: "Snake Plant",
                    scientificName: "Sansevieria trifasciata",
                    description: "The Snake Plant is nearly indestructible and one of the best air-purifying plants. Its stiff, upright leaves make it a bold architectural statement in any room.",
                    careLevel: "Very Easy",
                    wateringFrequency: "Every 2–6 weeks",
                    sunlight: "Any light — low to bright indirect",
                    pruningSteps: [
                        PruningStep(title: "Identify what to remove", detail: "Look for leaves with brown tips, wrinkled texture, or those leaning heavily to one side. These are candidates for removal.", sfSymbol: "magnifyingglass"),
                        PruningStep(title: "Prepare clean scissors", detail: "Sharp, sterile scissors or a knife are essential. Dirty tools can introduce bacteria into the cut.", sfSymbol: "scissors"),
                        PruningStep(title: "Cut at soil level", detail: "Slice the unwanted leaf cleanly at the base, right at or just below the soil line. This prevents stub rot.", sfSymbol: "arrow.down.to.line"),
                        PruningStep(title: "Trim brown tips", detail: "If only the tip is brown, cut it off in a V-shape following the leaf's natural point to keep it looking natural.", sfSymbol: "triangle"),
                        PruningStep(title: "Propagate the cuttings", detail: "Snake plant cuttings can be rooted in water or soil! Place a healthy cut leaf in a jar of water in bright light.", sfSymbol: "drop.fill"),
                    ]
                )
            )
        ]
    }
    
    // MARK: - AR Placement
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let selectedModel = selectedModel else {
            showAlert(message: "Please select a model first")
            return
        }
        
        let location = gesture.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        
        if let firstResult = results.first {
            placeModel(selectedModel, at: firstResult)
        } else {
            showAlert(message: "Unable to find a surface. Try moving your device.")
        }
    }
    
    func placeModel(_ model: ModelItem, at result: ARRaycastResult) {
        if let oldAnchor = currentAnchor {
            arView.scene.removeAnchor(oldAnchor)
        }
        
        // Dummy model: a green box representing the plant
        let mesh = MeshResource.generateBox(size: [0.15, 0.3, 0.15], cornerRadius: 0.02)
        let material = SimpleMaterial(color: UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0), isMetallic: false)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        currentModelEntity = modelEntity
        
        let anchor = AnchorEntity(world: result.worldTransform)
        anchor.addChild(modelEntity)
        arView.scene.addAnchor(anchor)
        currentAnchor = anchor
        
        modelEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation, .scale], for: modelEntity)
        
        // Show the info button with a nice animation
        showInfoButton.isHidden = false
        showInfoButton.alpha = 0
        showInfoButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.showInfoButton.alpha = 1
            self.showInfoButton.transform = .identity
        }
        
        // Show light panel with dummy reading
        lightMeterPanel.isHidden = false
        updateLightReading()
    }
    
    // MARK: - Show Info
    @objc func showInfoTapped() {
        guard let model = selectedModel, let info = model.plantInfo else { return }
        
        let sheet = PlantInfoSheetViewController(plantInfo: info)
        sheet.modalPresentationStyle = .pageSheet
        if let sheet = sheet.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 28
        }
        present(sheet, animated: true)
    }
    
    // MARK: - Light Meter (preserved)
    func updateLightReading() {
        guard let selectedModel = selectedModel,
              let lightReq = selectedModel.LightNeed else { return }
        let lightEstimate = getLightEstimate()
        currentLightLevel = lightEstimate
        updateLightMeterUI(lux: lightEstimate, requirement: lightReq)
    }
    
    func getLightEstimate() -> Float {
        if let lightEstimate = arView.session.currentFrame?.lightEstimate {
            let ambientIntensity = lightEstimate.ambientIntensity
            let approximateLux = Float(ambientIntensity) * 2.5
            return approximateLux
        }
        // Dummy fallback: simulate a realistic indoor lux reading (~1200–1800)
        let base: Float = 1500.0
        let jitter = Float.random(in: -300...300)
        return base + jitter
    }
    
    func updateLightMeterUI(lux: Float, requirement: LightNeed) {
        luxValueLabel.text = String(format: "%.0f lux", lux)
        let status = determineLightStatus(lux: lux, requirement: requirement)
        switch status {
        case .tooLow:
            lightStatusIcon.text = "🌙"
            lightLevelLabel.text = "TOO DARK"
            lightLevelLabel.textColor = .systemOrange
            lightRecommendationLabel.text = requirement.lowLightMessage
            lightMeterPanel.layer.borderColor = UIColor.systemOrange.cgColor
            lightMeterPanel.layer.borderWidth = 3
        case .optimal:
            lightStatusIcon.text = "☀️"
            lightLevelLabel.text = "PERFECT"
            lightLevelLabel.textColor = .systemGreen
            lightRecommendationLabel.text = requirement.optimalMessage
            lightMeterPanel.layer.borderColor = UIColor.systemGreen.cgColor
            lightMeterPanel.layer.borderWidth = 3
        case .tooHigh:
            lightStatusIcon.text = "🔆"
            lightLevelLabel.text = "TOO BRIGHT"
            lightLevelLabel.textColor = .systemRed
            lightRecommendationLabel.text = requirement.highLightMessage
            lightMeterPanel.layer.borderColor = UIColor.systemRed.cgColor
            lightMeterPanel.layer.borderWidth = 3
        case .acceptable:
            lightStatusIcon.text = "🌤️"
            lightLevelLabel.text = "ACCEPTABLE"
            lightLevelLabel.textColor = .systemYellow
            lightRecommendationLabel.text = "Light level is okay, but could be better. \(requirement.description)"
            lightMeterPanel.layer.borderColor = UIColor.systemYellow.cgColor
            lightMeterPanel.layer.borderWidth = 3
        }
        updateLightBar(lux: lux, requirement: requirement)
    }
    
    func determineLightStatus(lux: Float, requirement: LightNeed) -> LightStatus {
        if lux < requirement.minLux { return .tooLow }
        else if lux >= requirement.optimalMinLux && lux <= requirement.optimalMaxLux { return .optimal }
        else if lux > requirement.maxLux { return .tooHigh }
        else { return .acceptable }
    }
    
    func updateLightBar(lux: Float, requirement: LightNeed) {
        let percentage = min(max(lux / requirement.maxLux * 100, 0), 100)
        instructionLabel.text = String(format: "Light Level: %.0f%% of maximum", percentage)
    }
    
    enum LightStatus { case tooLow, acceptable, optimal, tooHigh }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ARViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelCell", for: indexPath) as! ModelCell
        let model = models[indexPath.item]
        cell.configure(with: model)
        cell.isSelectedCell = (selectedModel?.fileName == model.fileName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedModel = models[indexPath.item]
        collectionView.reloadData()
        instructionLabel.text = "Tap anywhere to place \(models[indexPath.item].name)"
        showInfoButton.isHidden = true
    }
}

// MARK: - Data Models

struct ModelItem {
    let name: String
    let fileName: String
    let thumbnail: String
    let LightNeed: LightNeed?
    let plantInfo: PlantInfo?
    
    init(name: String, fileName: String, thumbnail: String, LightNeed: LightNeed? = nil, plantInfo: PlantInfo? = nil) {
        self.name = name
        self.fileName = fileName
        self.thumbnail = thumbnail
        self.LightNeed = LightNeed
        self.plantInfo = plantInfo
    }
}

struct LightNeed {
    let plantName: String
    let minLux: Float
    let optimalMinLux: Float
    let optimalMaxLux: Float
    let maxLux: Float
    let lowLightMessage: String
    let optimalMessage: String
    let highLightMessage: String
    let description: String
}

struct PlantInfo {
    let commonName: String
    let scientificName: String
    let description: String
    let careLevel: String
    let wateringFrequency: String
    let sunlight: String
    let pruningSteps: [PruningStep]
}

struct PruningStep {
    let title: String
    let detail: String
    let sfSymbol: String   // SF Symbol name used as reference image
}

// MARK: - Plant Info Sheet

class PlantInfoSheetViewController: UIViewController {
    
    private let plantInfo: PlantInfo
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let green = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
    private let mintBg = UIColor(red: 0.93, green: 0.98, blue: 0.93, alpha: 1.0)
    
    init(plantInfo: PlantInfo) {
        self.plantInfo = plantInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        buildContent()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func buildContent() {
        // ── Header ──────────────────────────────────────────────
        let header = UIView()
        header.backgroundColor = mintBg
        
        let nameLabel = UILabel()
        nameLabel.text = plantInfo.commonName
        nameLabel.font = .systemFont(ofSize: 26, weight: .bold)
        nameLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.08, alpha: 1.0)
        
        let sciLabel = UILabel()
        sciLabel.text = plantInfo.scientificName
        sciLabel.font = .italicSystemFont(ofSize: 14)
        sciLabel.textColor = .secondaryLabel
        
        let descLabel = UILabel()
        descLabel.text = plantInfo.description
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .label
        descLabel.numberOfLines = 0
        
        let headerStack = UIStackView(arrangedSubviews: [nameLabel, sciLabel, descLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 6
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(headerStack)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: header.topAnchor, constant: 24),
            headerStack.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            headerStack.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -20),
        ])
        contentStack.addArrangedSubview(header)
        
        // ── Quick Stats Row ──────────────────────────────────────
        let statsRow = UIStackView()
        statsRow.axis = .horizontal
        statsRow.distribution = .fillEqually
        statsRow.spacing = 12
        statsRow.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 8, right: 20)
        statsRow.isLayoutMarginsRelativeArrangement = true
        
        statsRow.addArrangedSubview(makeStatBadge(icon: "drop.fill", label: plantInfo.wateringFrequency, color: .systemBlue))
        statsRow.addArrangedSubview(makeStatBadge(icon: "sun.max.fill", label: plantInfo.sunlight, color: .systemYellow))
        statsRow.addArrangedSubview(makeStatBadge(icon: "chart.bar.fill", label: plantInfo.careLevel, color: green))
        contentStack.addArrangedSubview(statsRow)
        
        // ── Pruning Title ────────────────────────────────────────
        let sectionHeader = UIView()
        sectionHeader.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 4, right: 20)
        
        let sectionTitle = UILabel()
        sectionTitle.text = "✂️  How to Prune"
        sectionTitle.font = .systemFont(ofSize: 19, weight: .bold)
        sectionTitle.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.08, alpha: 1.0)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        sectionHeader.addSubview(sectionTitle)
        NSLayoutConstraint.activate([
            sectionTitle.topAnchor.constraint(equalTo: sectionHeader.topAnchor, constant: 16),
            sectionTitle.leadingAnchor.constraint(equalTo: sectionHeader.leadingAnchor, constant: 20),
            sectionTitle.trailingAnchor.constraint(equalTo: sectionHeader.trailingAnchor, constant: -20),
            sectionTitle.bottomAnchor.constraint(equalTo: sectionHeader.bottomAnchor, constant: -4),
        ])
        contentStack.addArrangedSubview(sectionHeader)
        
        // ── Pruning Steps ────────────────────────────────────────
        let stepsContainer = UIView()
        stepsContainer.layoutMargins = UIEdgeInsets(top: 8, left: 20, bottom: 24, right: 20)
        
        let stepsStack = UIStackView()
        stepsStack.axis = .vertical
        stepsStack.spacing = 12
        stepsStack.translatesAutoresizingMaskIntoConstraints = false
        stepsContainer.addSubview(stepsStack)
        NSLayoutConstraint.activate([
            stepsStack.topAnchor.constraint(equalTo: stepsContainer.topAnchor, constant: 8),
            stepsStack.leadingAnchor.constraint(equalTo: stepsContainer.leadingAnchor, constant: 20),
            stepsStack.trailingAnchor.constraint(equalTo: stepsContainer.trailingAnchor, constant: -20),
            stepsStack.bottomAnchor.constraint(equalTo: stepsContainer.bottomAnchor, constant: -24),
        ])
        
        for (index, step) in plantInfo.pruningSteps.enumerated() {
            stepsStack.addArrangedSubview(makeStepCard(index: index + 1, step: step))
        }
        contentStack.addArrangedSubview(stepsContainer)
    }
    
    // ── Stat Badge ───────────────────────────────────────────────
    private func makeStatBadge(icon: String, label: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = color.withAlphaComponent(0.10)
        card.layer.cornerRadius = 14
        
        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = color
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 20).isActive = true
        img.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        let lbl = UILabel()
        lbl.text = label
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = color
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        
        let stack = UIStackView(arrangedSubviews: [img, lbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
        return card
    }
    
    // ── Step Card ────────────────────────────────────────────────
    private func makeStepCard(index: Int, step: PruningStep) -> UIView {
        let card = UIView()
        card.backgroundColor = mintBg
        card.layer.cornerRadius = 16
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 0.15).cgColor
        
        // Number badge
        let numBadge = UIView()
        numBadge.backgroundColor = green
        numBadge.layer.cornerRadius = 16
        numBadge.translatesAutoresizingMaskIntoConstraints = false
        numBadge.widthAnchor.constraint(equalToConstant: 32).isActive = true
        numBadge.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        let numLabel = UILabel()
        numLabel.text = "\(index)"
        numLabel.font = .systemFont(ofSize: 14, weight: .bold)
        numLabel.textColor = .white
        numLabel.textAlignment = .center
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numBadge.addSubview(numLabel)
        NSLayoutConstraint.activate([
            numLabel.centerXAnchor.constraint(equalTo: numBadge.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: numBadge.centerYAnchor),
        ])
        
        // SF Symbol image (reference illustration)
        let symbolBg = UIView()
        symbolBg.backgroundColor = green.withAlphaComponent(0.12)
        symbolBg.layer.cornerRadius = 14
        symbolBg.translatesAutoresizingMaskIntoConstraints = false
        symbolBg.widthAnchor.constraint(equalToConstant: 56).isActive = true
        symbolBg.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let symbolImg = UIImageView(image: UIImage(systemName: step.sfSymbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)))
        symbolImg.tintColor = green
        symbolImg.contentMode = .scaleAspectFit
        symbolImg.translatesAutoresizingMaskIntoConstraints = false
        symbolBg.addSubview(symbolImg)
        NSLayoutConstraint.activate([
            symbolImg.centerXAnchor.constraint(equalTo: symbolBg.centerXAnchor),
            symbolImg.centerYAnchor.constraint(equalTo: symbolBg.centerYAnchor),
            symbolImg.widthAnchor.constraint(equalToConstant: 28),
            symbolImg.heightAnchor.constraint(equalToConstant: 28),
        ])
        
        // Text
        let titleLabel = UILabel()
        titleLabel.text = step.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.08, alpha: 1.0)
        titleLabel.numberOfLines = 1
        
        let detailLabel = UILabel()
        detailLabel.text = step.detail
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        // Right content: symbol + text
        let rightStack = UIStackView(arrangedSubviews: [symbolBg, textStack])
        rightStack.axis = .horizontal
        rightStack.alignment = .top
        rightStack.spacing = 12
        
        // Full row: number badge + right content
        let rowStack = UIStackView(arrangedSubviews: [numBadge, rightStack])
        rowStack.axis = .horizontal
        rowStack.alignment = .top
        rowStack.spacing = 12
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            rowStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            rowStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            rowStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
        return card
    }
}

// MARK: - Model Cell
class ModelCell: UICollectionViewCell {
    
    let thumbnailLabel = UILabel()
    let nameLabel = UILabel()
    
    var isSelectedCell: Bool = false {
        didSet { updateSelection() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .darkGray
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor
        
        thumbnailLabel.font = UIFont.systemFont(ofSize: 30)
        thumbnailLabel.textAlignment = .center
        thumbnailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = UIFont.systemFont(ofSize: 10)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(thumbnailLabel)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            thumbnailLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            thumbnailLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: thumbnailLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
        ])
    }
    
    func configure(with model: ModelItem) {
        thumbnailLabel.text = model.thumbnail
        nameLabel.text = model.name
    }
    
    func updateSelection() {
        if isSelectedCell {
            layer.borderColor = UIColor.systemBlue.cgColor
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3)
        } else {
            layer.borderColor = UIColor.clear.cgColor
            backgroundColor = .darkGray
        }
    }
}
