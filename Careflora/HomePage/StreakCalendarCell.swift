import UIKit

class StreakCalendarCell: UICollectionViewCell {

    static let reuseIdentifier = "StreakCalendarCell"

    // MARK: - Theme
    private let botanicalGreen = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 1.0)
    private let brightGreen    = UIColor(red: 0.28, green: 0.72, blue: 0.28, alpha: 1.0)

    // MARK: - UI
    private let cardView       = UIView()
    private let leafIcon       = UIImageView()   // 🌿 leaf icon
    private let countLabel     = UILabel()       // "12"
    private let streakSubLabel = UILabel()       // "day streak"
    private let bestLabel      = UILabel()       // "Best: 15"
    private let divider        = UIView()
    private let dotsStack      = UIStackView()   // 7 day dots
    private var dotViews       = [UIView]()      // the 7 circles
    private var dayLabels      = [UILabel]()     // S M T W T F S

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }

    // MARK: - Build UI
    private func buildUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Card — very subtle green tint
        cardView.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 0.95, alpha: 1.0)
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 0.15).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        // Left side: leaf icon + count
        let leafConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold, scale: .medium)
        leafIcon.image = UIImage(systemName: "leaf.fill", withConfiguration: leafConfig)
        leafIcon.tintColor = botanicalGreen
        leafIcon.contentMode = .scaleAspectFit
        leafIcon.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(leafIcon)

        countLabel.font = UIFont.systemFont(ofSize: 32, weight: .black)
        countLabel.textColor = botanicalGreen
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(countLabel)

        streakSubLabel.text = "day streak"
        streakSubLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        streakSubLabel.textColor = UIColor.systemGray2
        streakSubLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(streakSubLabel)

        bestLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        bestLabel.textColor = UIColor.systemGray3
        bestLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(bestLabel)

        // Divider
        divider.backgroundColor = UIColor.systemGray5
        divider.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(divider)

        // Right side: 7-day dots
        buildDotsStack()

        // Constraints
        NSLayoutConstraint.activate([
            leafIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            leafIcon.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            leafIcon.widthAnchor.constraint(equalToConstant: 30),
            leafIcon.heightAnchor.constraint(equalToConstant: 30),

            countLabel.leadingAnchor.constraint(equalTo: leafIcon.trailingAnchor, constant: 6),
            countLabel.centerYAnchor.constraint(equalTo: leafIcon.centerYAnchor),

            streakSubLabel.leadingAnchor.constraint(equalTo: leafIcon.leadingAnchor),
            streakSubLabel.topAnchor.constraint(equalTo: leafIcon.bottomAnchor, constant: 2),

            bestLabel.leadingAnchor.constraint(equalTo: leafIcon.leadingAnchor),
            bestLabel.topAnchor.constraint(equalTo: streakSubLabel.bottomAnchor, constant: 2),

            divider.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 120),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            divider.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),

            dotsStack.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 14),
            dotsStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            dotsStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }

    private func buildDotsStack() {
        dotsStack.axis = .horizontal
        dotsStack.distribution = .fillEqually
        dotsStack.spacing = 4
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dotsStack)

        let dayInitials = lastSevenDayInitials()

        for i in 0..<7 {
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false

            let dot = UIView()
            dot.layer.cornerRadius = 10
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = UIColor.systemGray5
            container.addSubview(dot)

            let lbl = UILabel()
            lbl.text = dayInitials[i]
            lbl.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            lbl.textAlignment = .center
            lbl.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(lbl)

            NSLayoutConstraint.activate([
                dot.topAnchor.constraint(equalTo: container.topAnchor),
                dot.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                dot.widthAnchor.constraint(equalToConstant: 20),
                dot.heightAnchor.constraint(equalToConstant: 20),

                lbl.topAnchor.constraint(equalTo: dot.bottomAnchor, constant: 3),
                lbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            dotsStack.addArrangedSubview(container)
            dotViews.append(dot)
            dayLabels.append(lbl)
        }
    }

    // MARK: - Configure
    func configure() {
        let manager = StreakManager.shared
        countLabel.text = "\(manager.currentStreak)"
        bestLabel.text  = "Best: \(manager.longestStreak) days"

        let cal = Calendar.current
        let today = Date()

        for i in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: -(6 - i), to: today) else { continue }
            let isActive = manager.wasActive(on: day)
            let isToday  = cal.isDateInToday(day)

            let dot  = dotViews[i]
            let lbl  = dayLabels[i]

            if isActive {
                // Filled bright green
                dot.backgroundColor = brightGreen
                dot.layer.borderWidth = 0
                lbl.textColor = botanicalGreen
            } else if isToday {
                // Today ring
                dot.backgroundColor = .clear
                dot.layer.borderWidth = 2
                dot.layer.borderColor = botanicalGreen.cgColor
                lbl.textColor = botanicalGreen
            } else {
                // Inactive
                dot.backgroundColor = UIColor.systemGray5
                dot.layer.borderWidth = 0
                lbl.textColor = UIColor.systemGray3
            }
        }
    }

    private func lastSevenDayInitials() -> [String] {
        let cal      = Calendar.current
        let today    = Date()
        let symbols  = ["S","M","T","W","T","F","S"]
        var result   = [String]()

        for i in (0..<7).reversed() {
            if let day = cal.date(byAdding: .day, value: -i, to: today) {
                let weekday = cal.component(.weekday, from: day) - 1
                result.append(symbols[weekday])
            }
        }
        return result
    }
}
