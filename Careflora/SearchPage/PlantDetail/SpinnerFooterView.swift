import UIKit

/// Footer shown at the bottom of the plant list while more items are being loaded.
final class SpinnerFooterView: UICollectionReusableView {
    
    static let identifier = "SpinnerFooterView"
    
    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.color = UIColor(red: 0.25, green: 0.50, blue: 0.30, alpha: 1.0)
        s.hidesWhenStopped = false
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "Loading more plants..."
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = UIColor(red: 0.25, green: 0.50, blue: 0.30, alpha: 1.0)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack.addArrangedSubview(spinner)
        stack.addArrangedSubview(label)
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func startAnimating() {
        isHidden = false
        spinner.startAnimating()
        // Smooth fade in
        alpha = 0
        UIView.animate(withDuration: 0.3) { self.alpha = 1 }
    }
    
    func stopAnimating() {
        UIView.animate(withDuration: 0.2) { self.alpha = 0 } completion: { _ in
            self.spinner.stopAnimating()
            self.isHidden = true
        }
    }
}
