import UIKit

class PlantRowCell: UICollectionViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var mainContainerView: UIView! // The "Card" layer
    
    @IBOutlet weak var doneBackgroundView: UIView!
    
    var onDone: (() -> Void)?
    private var panRecognizer: UIPanGestureRecognizer!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupPanGesture()
        // Replace 'doneBackgroundView' with whatever you named that outlet
        doneBackgroundView.layer.cornerRadius = 16
        doneBackgroundView.layer.masksToBounds = true
    }
    
    
    
    
    private func setupUI() {
        // Round the corners of the foreground card
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.masksToBounds = true
        
        // Round the image
        plantImageView.layer.cornerRadius = 8
        plantImageView.clipsToBounds = true
    }

    private func setupPanGesture() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panRecognizer.delegate = self // This links to the extension below
        self.addGestureRecognizer(panRecognizer)
    }

    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        
        switch recognizer.state {
        case .changed:
            if translation.x < 0 { // Only swipe left
                mainContainerView.transform = CGAffineTransform(translationX: translation.x, y: 0)
                // Fade effect
                let progress = abs(translation.x) / self.bounds.width
                mainContainerView.alpha = 1.0 - (progress * 0.5)
            }
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: self).x
            let dragDistance = translation.x
            
            // If dragged 40% of the way or swiped fast
            if dragDistance < -(self.bounds.width * 0.4) || velocity < -500 {
                completeSwipe()
            } else {
                // Snap back with a spring bounce
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
                    self.mainContainerView.transform = .identity
                    self.mainContainerView.alpha = 1.0
                }
            }
        default: break
        }
    }

    private func completeSwipe() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.2, animations: {
            self.mainContainerView.transform = CGAffineTransform(translationX: -self.bounds.width, y: 0)
            self.mainContainerView.alpha = 0
        }) { _ in
            self.onDone?()
        }
    }

    func configure(with userPlant: UserPlant,
                   task: String,
                   allPlants: [Plant]) {

        // ✅ Find matching plant using plantId
        if let plant = allPlants.first(where: { $0.plantId == userPlant.plantId }) {

            // ✅ Plant Name from JSON
            nameLabel.text = plant.plantName

            // ✅ Image Priority:
            // 1. User saved image
            // 2. JSON fallback
            if let data = userPlant.imageData,
               let savedImage = UIImage(data: data) {

                plantImageView.image = savedImage

            } else {
                plantImageView.image =
                    UIImage(named: plant.imageName)
                    ?? UIImage(systemName: "leaf.fill")
            }

        } else {

            // ❌ Plant not found
            nameLabel.text = "Unknown Plant"
            plantImageView.image = UIImage(systemName: "leaf.fill")
        }

        // ✅ Detail label
        detailLabel.text = "Swipe to mark \(task) done"

        // ✅ Reset swipe UI (important!)
        mainContainerView.transform = .identity
        mainContainerView.alpha = 1.0
    }





}

// MARK: - Gesture Delegate (The scrolling fix)
extension PlantRowCell: UIGestureRecognizerDelegate {
    
    // Allows vertical scroll and horizontal swipe to exist together
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)
            // If moving more horizontally than vertically, "lock" onto the swipe
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
}
