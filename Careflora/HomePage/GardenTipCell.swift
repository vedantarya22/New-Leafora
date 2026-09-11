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
        pillView.layer.cornerRadius = 14
        pillView.clipsToBounds      = true
        cardBackground.addSubview(pillView)
        
        pillIcon.image         = UIImage(systemName: "leaf.fill")
        pillIcon.tintColor     = .white
        pillIcon.contentMode   = .scaleAspectFit
        pillView.addSubview(pillIcon)
        
        pillLabel.text      = "GARDEN TIP"
        pillLabel.font      = .systemFont(ofSize: 12, weight: .bold)
        pillLabel.textColor = .white
        pillView.addSubview(pillLabel)
        
        // Tip message — dark, elegant, readable
        msgLabel.font          = .systemFont(ofSize: 16, weight: .medium)
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
        let pillH: CGFloat = 28
        let pillIconW: CGFloat = 14
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
        pillLabel.text = "GARDEN TIP"
        pillView.backgroundColor = UIColor(red: 0.18, green: 0.55, blue: 0.30, alpha: 1.0)
        pillIcon.image = UIImage(systemName: "leaf.fill")
        
        if let name = tip.imageName, let img = UIImage(named: name) {
            photoView.image = img
        } else {
            photoView.image        = UIImage(systemName: "leaf.fill")
            photoView.tintColor    = UIColor(red: 0.45, green: 0.70, blue: 0.55, alpha: 1.0)
            photoView.backgroundColor = UIColor(red: 0.88, green: 0.95, blue: 0.88, alpha: 1.0)
        }
    }
    
    func showLoading() {
        msgLabel.text = "Fetching weather-based tips..."
        pillLabel.text = "LOADING"
        pillView.backgroundColor = .systemGray
        pillIcon.image = UIImage(systemName: "arrow.triangle.2.circlepath")
        photoView.image = nil
        photoView.backgroundColor = UIColor(red: 0.94, green: 0.98, blue: 0.94, alpha: 1.0)
    }
    
    func showError() {
        msgLabel.text = "Could not fetch weather tips. Check your connection."
        pillLabel.text = "ERROR"
        pillView.backgroundColor = .systemOrange
        pillIcon.image = UIImage(systemName: "exclamationmark.triangle.fill")
        photoView.image = nil
        photoView.backgroundColor = UIColor(red: 0.98, green: 0.94, blue: 0.94, alpha: 1.0)
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
    
    static func randomTip(for weather: PlantWeatherInfo? = nil) -> GardenTip {
        // Fallback or generic tips
        let genericTips = [
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
        
        guard let weather = weather else {
            return genericTips.randomElement() ?? genericTips[0]
        }
        
        let condition = weather.condition.lowercased()
        let temp = weather.temperature
        
        var specificTips: [GardenTip] = []
        
        // Context 1: Hot or Clear/Sunny
        if temp >= 30 || condition.contains("clear") {
            specificTips.append(contentsOf: [
                GardenTip(message: "Hot weather! Water your plants deeply in the early morning to reduce evaporation.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=watering+plants+in+heat"),
                GardenTip(message: "Apply a layer of mulch to keep the roots cool and retain soil moisture.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=mulching+for+heat+protection"),
                GardenTip(message: "Strong sun can scorch leaves. Consider moving sensitive potted plants to partial shade.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=sun+scorch+on+plants")
            ])
        }
        
        // Context 2: Rainy or Humid
        if condition.contains("rain") || condition.contains("drizzle") || condition.contains("thunder") {
            specificTips.append(contentsOf: [
                GardenTip(message: "Rainy days! Skip your current watering schedule to avoid root rot.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=overwatering+rainy+days"),
                GardenTip(message: "High humidity during rain is great for tropicals, but watch out for fungal diseases.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=preventing+fungal+disease+in+plants"),
                GardenTip(message: "Ensure outdoor pots have proper drainage so they don't get waterlogged.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=potted+plant+drainage")
            ])
        }
        
        // Context 3: Cold or Snowy
        if temp <= 15 || condition.contains("snow") || condition.contains("ice") {
            specificTips.append(contentsOf: [
                GardenTip(message: "Cold snap incoming! Move delicate potted outdoor plants indoors.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=protecting+plants+from+frost"),
                GardenTip(message: "Reduce watering as plant growth slows during colder temperatures.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=winter+watering+plants"),
                GardenTip(message: "Keep indoor plants away from cold, drafty windows and heating vents.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=indoor+plants+winter+care")
            ])
        }
        
        // Context 4: Cloudy/Mist/Fog
        if condition.contains("cloud") || condition.contains("fog") || condition.contains("mist") {
            specificTips.append(contentsOf: [
                GardenTip(message: "Cloudy days are perfect for transplanting or repotting, as it reduces plant shock.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=transplanting+cloudy+day"),
                GardenTip(message: "Indoor plants might need to be moved closer to windows to maximize the available weak light.",
                          imageName: "mytip",
                          sourceURL: "https://www.gardeningknowhow.com/search?q=low+light+indoor+plants")
            ])
        }
        
        // If we found specific weather tips, pick one. Otherwise fallback to generic.
        if !specificTips.isEmpty {
            return specificTips.randomElement()!
        }
        
        return genericTips.randomElement() ?? genericTips[0]
    }
}
