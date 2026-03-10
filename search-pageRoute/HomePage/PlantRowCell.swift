import UIKit
import SDWebImage

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

    func configure(with userPlant: UserPlant, task: String, allPlants: [Plant]) {

        // ✅ Match by mongoId — userPlant.plantId stores MongoDB ObjectId
        if let plant = allPlants.first(where: { $0.mongoId == userPlant.plantId }) {

            nameLabel.text = plant.plantName

            // ✅ Image priority: local data → Cloudinary URL → catalogue URL → placeholder
            if let data = userPlant.imageData, let savedImage = UIImage(data: data) {
                plantImageView.image = savedImage
            } else if let urlString = userPlant.imageUrl, let url = URL(string: urlString) {
                // ✅ Cloudinary URL from MongoDB
                plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill"))
            } else if let url = URL(string: plant.imageName) {
                // ✅ Fallback to catalogue image
                plantImageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "leaf.fill"))
            } else {
                plantImageView.image = UIImage(systemName: "leaf.fill")
            }

            detailLabel.text = getTaskDetail(for: task, plant: plant)

        } else {
            nameLabel.text = "Unknown Plant"
            plantImageView.image = UIImage(systemName: "leaf.fill")
            detailLabel.text = "Unknown"
        }

        mainContainerView.transform = .identity
        mainContainerView.alpha = 1.0
    }
    
    
    private func getTaskDetail(for task: String, plant: Plant) -> String {
          switch task.lowercased() {
       case "watering":
           return getWateringDetail(plant: plant)

          case "fertilizing":
           return getFertilizingDetail(plant: plant)

       case "pruning":
            return getPruningDetail(plant: plant)

        case "repotting":
            return getRepottingDetail(plant: plant)
  
         default:
              return plant.careCycle.watering.display
         }
    }
    
    private func getWateringDetail(plant: Plant) -> String {
        let method = plant.careCycle.watering.method?.lowercased() ?? "moderate"

        switch method {
         case "spray":
           return "Spray misting"
       case "light":
          return "Light watering"
       case "moderate":
           return "Moderate watering"
        case "deep":
           return "Deep watering"
         case "bottom":
            return "Bottom watering"
        default:
            return "Moderate watering"
         }
     }
    
    private func getFertilizingDetail(plant: Plant) -> String {
         let method = plant.careCycle.fertilizing.method?.lowercased() ?? "balanced"
   
          switch method {
         case "light":
             return "Light feeding"
          case "balanced":
            return "Balanced feeding"
         case "heavy":
          return "Heavy feeding"
          case "organic":
            return "Organic compost"
       default:
            return "Balanced feeding"
           }
       }
   
      private func getPruningDetail(plant: Plant) -> String {
          let method = plant.careCycle.pruning.method?.lowercased() ?? "trim"
 
       switch method {
         case "trim":
           return "Light trimming"
         case "shape":
            return "Shape pruning"
         case "heavy":
            return "Heavy pruning"
          case "pinch":
           return "Pinching back"
          default:
            return "Light trimming"
        }
   }

    private func getRepottingDetail(plant: Plant) -> String {
        let method = plant.careCycle.repotting.method?.lowercased() ?? "refresh"
   
        switch method {
        case "check":
           return "Root check needed"
      case "upgrade":
           return "Pot upgrade needed"
       case "refresh":
            return "Soil refresh needed"
       case "division":
               return "Division needed"
         default:
           return "Soil refresh needed"
         }
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
