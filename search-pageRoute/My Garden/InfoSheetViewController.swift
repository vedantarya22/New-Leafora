import UIKit

final class InfoSheetViewController: UIViewController {

    // MARK: - Init (plain primitives — no shared model types needed)

    private let plantName:   String
    private let thumbnail:   String
    private let plantDescription: String
    private let minLux:      Float
    private let maxLux:      Float

    init(plantName: String, thumbnail: String, plantDescription: String, minLux: Float, maxLux: Float) {
        self.plantName   = plantName
        self.thumbnail   = thumbnail
        self.plantDescription = plantDescription
        self.minLux      = minLux
        self.maxLux      = maxLux
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    // MARK: - UI

    private func buildUI() {
        view.backgroundColor = UIColor(white: 0.12, alpha: 1)

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis      = .vertical
        content.spacing   = 0
        content.alignment = .fill
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor)
        ])

        // Drag handle
        let handle = UIView()
        handle.backgroundColor    = UIColor(white: 0.4, alpha: 1)
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(handle)
        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 36),
            handle.heightAnchor.constraint(equalToConstant: 5)
        ])

        content.addArrangedSubview(buildHeader())
        content.addArrangedSubview(buildDivider())
        content.addArrangedSubview(buildSectionHeader("How to Place"))
        for (i, step) in defaultSteps().enumerated() {
            content.addArrangedSubview(buildStepRow(number: i + 1, text: step))
        }
        content.addArrangedSubview(buildDivider())
        content.addArrangedSubview(buildSectionHeader("Light Meter Guide"))
        content.addArrangedSubview(buildLightGuide())
        content.addArrangedSubview(buildDivider())
        content.addArrangedSubview(buildSectionHeader("AR Tips"))
        for tip in buildTips() {
            content.addArrangedSubview(buildTipRow(tip))
        }

        let pad = UIView()
        pad.heightAnchor.constraint(equalToConstant: 48).isActive = true
        content.addArrangedSubview(pad)
    }

    private func buildDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.07)
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }

    private func buildHeader() -> UIView {
        let container = UIView()
        container.layoutMargins = UIEdgeInsets(top: 36, left: 24, bottom: 20, right: 24)

        let badge  = UILabel()
        badge.text = thumbnail
        badge.font = .systemFont(ofSize: 44)

        let title  = UILabel()
        title.text      = plantName
        title.font      = .systemFont(ofSize: 26, weight: .bold)
        title.textColor = .white

        let stack = UIStackView(arrangedSubviews: [badge, title])
        stack.axis      = .vertical
        stack.spacing   = 10
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        if minLux > 0 {
            let tag = UIView()
            tag.backgroundColor    = UIColor.systemGreen.withAlphaComponent(0.15)
            tag.layer.cornerRadius = 8
            tag.layer.borderColor  = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
            tag.layer.borderWidth  = 1

            let lbl = UILabel()
            lbl.text      = "💡 \(Int(minLux))–\(Int(maxLux)) Lux"
            lbl.font      = .monospacedSystemFont(ofSize: 12, weight: .semibold)
            lbl.textColor = .systemGreen
            lbl.translatesAutoresizingMaskIntoConstraints = false
            tag.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: tag.topAnchor, constant: 6),
                lbl.bottomAnchor.constraint(equalTo: tag.bottomAnchor, constant: -6),
                lbl.leadingAnchor.constraint(equalTo: tag.leadingAnchor, constant: 10),
                lbl.trailingAnchor.constraint(equalTo: tag.trailingAnchor, constant: -10)
            ])
            stack.addArrangedSubview(tag)
        }

        if !plantDescription.isEmpty {
            let desc = UILabel()
            desc.text      = plantDescription
            desc.font      = .systemFont(ofSize: 13)
            desc.textColor = UIColor(white: 0.75, alpha: 1)
            desc.numberOfLines = 0
            stack.addArrangedSubview(desc)
        }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor)
        ])
        return container
    }

    private func buildSectionHeader(_ text: String) -> UIView {
        let container = UIView()
        let lbl = UILabel()
        lbl.text      = text.uppercased()
        lbl.font      = .systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = UIColor(white: 0.5, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24)
        ])
        return container
    }

    private func buildStepRow(number: Int, text: String) -> UIView {
        let row = UIView()
        row.layoutMargins = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)

        let num = UILabel()
        num.text            = "\(number)"
        num.font            = .systemFont(ofSize: 12, weight: .bold)
        num.textColor       = .white
        num.backgroundColor = .systemBlue
        num.textAlignment   = .center
        num.layer.cornerRadius = 12
        num.clipsToBounds   = true
        num.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text          = text
        lbl.font          = .systemFont(ofSize: 14)
        lbl.textColor     = UIColor(white: 0.9, alpha: 1)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(num)
        row.addSubview(lbl)
        NSLayoutConstraint.activate([
            num.leadingAnchor.constraint(equalTo: row.layoutMarginsGuide.leadingAnchor),
            num.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
            num.widthAnchor.constraint(equalToConstant: 24),
            num.heightAnchor.constraint(equalToConstant: 24),
            lbl.leadingAnchor.constraint(equalTo: num.trailingAnchor, constant: 12),
            lbl.trailingAnchor.constraint(equalTo: row.layoutMarginsGuide.trailingAnchor),
            lbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),
            lbl.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -10)
        ])
        return row
    }

    private func buildLightGuide() -> UIView {
        let entries: [(String, String, UIColor)] = [
            ("✨", "Perfect — ideal light for this plant",       .systemGreen),
            ("🌤", "Acceptable — slightly off but manageable",   .systemYellow),
            ("🌙", "Too Dark — move closer to a window",         .systemOrange),
            ("☀️", "Too Bright — risk of leaf burn",             .systemRed)
        ]

        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        for (icon, text, color) in entries {
            let row = UIStackView()
            row.axis      = .horizontal
            row.spacing   = 10
            row.alignment = .center

            let iconLbl = UILabel()
            iconLbl.text = icon
            iconLbl.font = .systemFont(ofSize: 20)
            iconLbl.setContentHuggingPriority(.required, for: .horizontal)

            let dot = UIView()
            dot.backgroundColor    = color
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 8).isActive  = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

            let textLbl = UILabel()
            textLbl.text          = text
            textLbl.font          = .systemFont(ofSize: 13)
            textLbl.textColor     = UIColor(white: 0.8, alpha: 1)
            textLbl.numberOfLines = 0

            row.addArrangedSubview(iconLbl)
            row.addArrangedSubview(dot)
            row.addArrangedSubview(textLbl)
            stack.addArrangedSubview(row)
        }

        let container = UIView()
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }

    private func buildTipRow(_ text: String) -> UIView {
        let lbl = UILabel()
        lbl.text          = "• \(text)"
        lbl.font          = .systemFont(ofSize: 13)
        lbl.textColor     = UIColor(white: 0.55, alpha: 1)
        lbl.numberOfLines = 0
        let container = UIView()
        container.addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            lbl.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            lbl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            lbl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24)
        ])
        return container
    }

    private func buildTips() -> [String] {
        ["Move your phone slowly when scanning",
         "Pinch to scale the model up or down",
         "Tap once to place, drag to reposition",
         "Good lighting helps ARKit track surfaces faster"]
    }

    private func defaultSteps() -> [String] {
        ["Point the camera at a flat floor or table",
         "Wait for the yellow tracking dots to appear",
         "Tap the screen to place your plant",
         "Check the light meter panel for care advice"]
    }
}
