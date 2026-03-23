//
//  GardenTipCell.swift
//  homescreen1
//
//  Created by SDC-USER on 10/02/26.
//

import UIKit

class GardenTipCell: UICollectionViewCell {
    
    // Callback to open source URL
    var onTipTapped: (() -> Void)?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tipTitleLabel: UILabel!
    @IBOutlet weak var tipMessageLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    // MARK: - Programmatic UI
    private let cardBackground = UIView()
    private let photoView      = UIImageView()
    private let pillView       = UIView()
    private let pillIcon       = UIImageView()
    private let pillLabel      = UILabel()
    private let msgLabel       = UILabel()
    private let divider        = UIView()
    
    private var didBuild = false
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Hide XIB outlets – we build our own layout
        tipTitleLabel.isHidden  = true
        tipMessageLabel.isHidden = true
        plantImageView.isHidden = true
        containerView.isHidden  = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didBuild { buildLayout(); didBuild = true }
        layoutFrames()
    }
    
    // MARK: - Build (once)
    private func buildLayout() {
        self.backgroundColor = .clear
        self.layer.shadowColor   = UIColor.black.cgColor
        self.layer.shadowOffset  = CGSize(width: 0, height: 3)
        self.layer.shadowRadius  = 10
        self.layer.shadowOpacity = 0.08
        self.layer.masksToBounds = false
        
        // White card
        cardBackground.backgroundColor  = .white
        cardBackground.layer.cornerRadius = 20
        cardBackground.layer.masksToBounds = true
        self.addSubview(cardBackground)
        
        // Tap gesture to open source article
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cardBackground.addGestureRecognizer(tap)
        cardBackground.isUserInteractionEnabled = true
        
        // Photo (top ~55%)
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        cardBackground.addSubview(photoView)
        
        // Subtle divider line between photo and text
        divider.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 1.0)
        cardBackground.addSubview(divider)
        
        // Bottom text area bg — same mint as the app background
        let textBg = UIView()
        textBg.backgroundColor = UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0)
        textBg.tag = 99
        cardBackground.addSubview(textBg)
        
        // Solid green pill:  GARDEN TIP
        pillView.backgroundColor    = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        pillView.layer.cornerRadius = 11
        pillView.clipsToBounds      = true
        cardBackground.addSubview(pillView)
        
        pillIcon.image         = UIImage(systemName: "leaf.fill")
        pillIcon.tintColor     = .white
        pillIcon.contentMode   = .scaleAspectFit
        pillView.addSubview(pillIcon)
        
        pillLabel.text      = "GARDEN TIP"
        pillLabel.font      = .systemFont(ofSize: 10, weight: .bold)
        pillLabel.textColor = .white
        pillView.addSubview(pillLabel)
        
        // Tip message — dark, bold, readable
        msgLabel.font          = .systemFont(ofSize: 16, weight: .semibold)
        msgLabel.textColor     = UIColor(red: 0.10, green: 0.18, blue: 0.10, alpha: 1.0)
        msgLabel.numberOfLines = 0
        msgLabel.lineBreakMode = .byWordWrapping
        cardBackground.addSubview(msgLabel)
    }
    
    // MARK: - Frame layout (every layoutSubviews)
    private func layoutFrames() {
        let w = bounds.width
        let h = bounds.height
        
        cardBackground.frame = bounds
        self.layer.cornerRadius = 20
        
        let photoH   = h * 0.48
        let pad: CGFloat = 14
        let pillH: CGFloat = 22
        let pillIconW: CGFloat = 11
        let pillLabelSize = pillLabel.sizeThatFits(CGSize(width: 200, height: pillH))
        let pillW = pad + pillIconW + 5 + pillLabelSize.width + pad
        
        // Photo fills top
        photoView.frame = CGRect(x: 0, y: 0, width: w, height: photoH)
        
        // Gradient fade at bottom of photo — transparent → mint, no hard line
        if photoView.layer.sublayers?.contains(where: { $0.name == "fadeGradient" }) == false {
            let fade = CAGradientLayer()
            fade.name = "fadeGradient"
            fade.colors = [
                UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 0.0).cgColor,
                UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 0.6).cgColor,
                UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0).cgColor
            ]
            fade.locations = [0.45, 0.78, 1.0]
            fade.startPoint = CGPoint(x: 0.5, y: 0)
            fade.endPoint   = CGPoint(x: 0.5, y: 1)
            fade.frame      = photoView.bounds
            photoView.layer.addSublayer(fade)
        } else if let fade = photoView.layer.sublayers?.first(where: { $0.name == "fadeGradient" }) {
            fade.frame = photoView.bounds
        }
        
        // No hard divider needed
        divider.frame = .zero
        
        // Mint text background fills bottom
        if let textBg = cardBackground.viewWithTag(99) {
            textBg.frame = CGRect(x: 0, y: photoH, width: w, height: h - photoH)
        }
        
        // Pill sits top of text area
        let pillY = photoH + pad
        pillView.frame   = CGRect(x: pad, y: pillY, width: pillW, height: pillH)
        pillIcon.frame   = CGRect(x: pad, y: (pillH - pillIconW) / 2, width: pillIconW, height: pillIconW)
        pillLabel.frame  = CGRect(x: pad + pillIconW + 5, y: 0, width: pillLabelSize.width + 4, height: pillH)
        
        // Message below pill
        let msgY = pillY + pillH + 5
        msgLabel.frame = CGRect(x: pad, y: msgY, width: w - pad * 2, height: h - msgY - 6)
    }
    
    // MARK: - Configure
    func configure(tip: GardenTip) {
        msgLabel.text = tip.message
        
        if let name = tip.imageName, let img = UIImage(named: name) {
            photoView.image = img
        } else {
            photoView.image        = UIImage(systemName: "leaf.fill")
            photoView.tintColor    = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
            photoView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 1.0)
        }
    }
    
    @objc private func handleTap() {
        onTipTapped?()
    }
}

// MARK: - Garden Tip Model
struct GardenTip {
    let message: String
    let imageName: String?
    let sourceURL: String
    
    static func randomTip() -> GardenTip {
        // All tips now sourced from "Gardening Know How", a reputable daily-publishing gardening site.
        // Using search queries to ensure links never 404 and always surface their latest articles on the topic.
        let tips = [
            GardenTip(message: "Water your succulents only when the soil is completely dry.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=watering+succulents"),
            GardenTip(message: "Increase humidity for tropical plants using pebble water trays.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=increase+plant+humidity"),
            GardenTip(message: "Most houseplants thrive in bright, indirect sunlight.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=houseplant+sunlight"),
            GardenTip(message: "Remove dead or yellowing leaves to encourage healthy new growth.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=pruning+houseplants"),
            GardenTip(message: "Repot your plant when you see roots growing through the drainage holes.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=repotting+houseplants"),
            GardenTip(message: "Group plants with similar watering needs together for easier care.",
                      imageName: "mytip",
                      sourceURL: "https://www.gardeningknowhow.com/search?q=grouping+houseplants"),
        ]
        return tips.randomElement() ?? tips[0]
    }
}

  

