import UIKit

extension UIView {
    
    /// Starts a beautiful, soft shimmering animation on the view to indicate loading.
    func startShimmering() {
        // Remove any existing shimmer
        stopShimmering()
        
        let light = UIColor(white: 0, alpha: 0.05).cgColor
        let dark = UIColor(white: 0, alpha: 0.15).cgColor
        
        let gradient = CAGradientLayer()
        gradient.colors = [light, dark, light]
        gradient.frame = CGRect(x: -bounds.size.width, y: 0, width: 3 * bounds.size.width, height: bounds.size.height)
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.name = "shimmerLayer"
        
        self.layer.addSublayer(gradient)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.2
        animation.isRemovedOnCompletion = false
        
        gradient.add(animation, forKey: "shimmer")
    }
    
    /// Stops the shimmering animation and removes the layer.
    func stopShimmering() {
        self.layer.sublayers?.filter { $0.name == "shimmerLayer" }.forEach { $0.removeFromSuperlayer() }
    }
}
