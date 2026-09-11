import UIKit

class StreakCalendarViewController: UIViewController {

    private let botanicalGreen = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 1.0)
    private let lightGreenBG = UIColor(red: 0.95, green: 0.99, blue: 0.95, alpha: 1.0)
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let streakCountLabel = UILabel()
    private let streakLabel = UILabel()
    private let bestStreakLabel = UILabel()
    
    private let calendarContainer = UIView()
    private let calendarTitleLabel = UILabel()
    private let weekdayStackView = UIStackView()
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var displayedMonth = Date()
    private var calendarDays: [Date?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshCalendar()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "My Streak"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem?.tintColor = botanicalGreen
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Header Section
        let headerCard = UIView()
        headerCard.backgroundColor = lightGreenBG
        headerCard.layer.cornerRadius = 24
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerCard)
        
        streakCountLabel.text = "\(StreakManager.shared.currentStreak)"
        streakCountLabel.font = .systemFont(ofSize: 64, weight: .black)
        streakCountLabel.textColor = botanicalGreen
        streakCountLabel.textAlignment = .center
        streakCountLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(streakCountLabel)
        
        streakLabel.text = "DAY STREAK"
        streakLabel.font = .systemFont(ofSize: 14, weight: .bold)
        streakLabel.textColor = botanicalGreen.withAlphaComponent(0.6)
        streakLabel.textAlignment = .center
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(streakLabel)
        
        bestStreakLabel.text = "Personal Best: \(StreakManager.shared.longestStreak) days"
        bestStreakLabel.font = .systemFont(ofSize: 14, weight: .medium)
        bestStreakLabel.textColor = botanicalGreen.withAlphaComponent(0.8)
        bestStreakLabel.textAlignment = .center
        bestStreakLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bestStreakLabel)
        
        // Calendar Section
        calendarContainer.backgroundColor = .white
        calendarContainer.layer.cornerRadius = 20
        calendarContainer.layer.shadowColor = UIColor.black.cgColor
        calendarContainer.layer.shadowOpacity = 0.05
        calendarContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        calendarContainer.layer.shadowRadius = 12
        calendarContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarContainer)
        
        calendarTitleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        calendarTitleLabel.textColor = .black
        calendarTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.addSubview(calendarTitleLabel)
        
        setupWeekdayStack()
        
        daysCollectionView.backgroundColor = .clear
        daysCollectionView.dataSource = self
        daysCollectionView.delegate = self
        daysCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.addSubview(daysCollectionView)
        
        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            headerCard.heightAnchor.constraint(equalToConstant: 160),
            
            streakCountLabel.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor, constant: -10),
            streakCountLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            
            streakLabel.topAnchor.constraint(equalTo: streakCountLabel.bottomAnchor, constant: -8),
            streakLabel.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            
            bestStreakLabel.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 16),
            bestStreakLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            calendarContainer.topAnchor.constraint(equalTo: bestStreakLabel.bottomAnchor, constant: 24),
            calendarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            calendarContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            calendarTitleLabel.topAnchor.constraint(equalTo: calendarContainer.topAnchor, constant: 20),
            calendarTitleLabel.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 20),
            
            weekdayStackView.topAnchor.constraint(equalTo: calendarTitleLabel.bottomAnchor, constant: 20),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 20),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: -20),
            
            daysCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 12),
            daysCollectionView.leadingAnchor.constraint(equalTo: calendarContainer.leadingAnchor, constant: 16),
            daysCollectionView.trailingAnchor.constraint(equalTo: calendarContainer.trailingAnchor, constant: -16),
            daysCollectionView.bottomAnchor.constraint(equalTo: calendarContainer.bottomAnchor, constant: -20),
            daysCollectionView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func setupWeekdayStack() {
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        calendarContainer.addSubview(weekdayStackView)
        
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        for day in days {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12, weight: .bold)
            label.textColor = botanicalGreen.withAlphaComponent(0.4)
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func refreshCalendar() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        calendarTitleLabel.text = formatter.string(from: displayedMonth).uppercased()
        
        calendarDays = buildCalendarDays(for: displayedMonth)
        daysCollectionView.reloadData()
    }
    
    private func buildCalendarDays(for monthDate: Date) -> [Date?] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: monthDate),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: monthDate)) else {
            return []
        }
        
        let weekday = cal.component(.weekday, from: firstDay)
        let prefixEmpties = weekday - 1
        
        var days: [Date?] = Array(repeating: nil, count: prefixEmpties)
        for day in range {
            var comps = cal.dateComponents([.year, .month], from: monthDate)
            comps.day = day
            days.append(cal.date(from: comps))
        }
        
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true)
    }
}

extension StreakCalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarDays.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        let date = calendarDays[indexPath.item]
        
        if let date = date {
            let day = Calendar.current.component(.day, from: date)
            let isActive = StreakManager.shared.wasActive(on: date)
            let isToday = Calendar.current.isDateInToday(date)
            cell.configure(day: day, isActive: isActive, isToday: isToday)
        } else {
            cell.configure(day: nil, isActive: false, isToday: false)
        }
        
        return cell
    }
    
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = cv.bounds.width / 7
        return CGSize(width: width, height: 40)
    }
}

class CalendarDayCell: UICollectionViewCell {
    private let label = UILabel()
    private let bgView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        bgView.layer.cornerRadius = 16
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            bgView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bgView.widthAnchor.constraint(equalToConstant: 32),
            bgView.heightAnchor.constraint(equalToConstant: 32),
            
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(day: Int?, isActive: Bool, isToday: Bool) {
        if let day = day {
            label.text = "\(day)"
            
            if isActive {
                bgView.backgroundColor = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 1.0)
                bgView.layer.borderWidth = 0
                label.textColor = .white
                label.font = .systemFont(ofSize: 14, weight: .black)
            } else if isToday {
                bgView.backgroundColor = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 0.1)
                bgView.layer.borderWidth = 2
                bgView.layer.borderColor = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 1.0).cgColor
                label.textColor = UIColor(red: 0.21, green: 0.49, blue: 0.16, alpha: 1.0)
                label.font = .systemFont(ofSize: 14, weight: .bold)
            } else {
                bgView.backgroundColor = .clear
                bgView.layer.borderWidth = 0
                label.textColor = .black.withAlphaComponent(0.8)
                label.font = .systemFont(ofSize: 14, weight: .medium)
            }
        } else {
            label.text = ""
            bgView.backgroundColor = .clear
            bgView.layer.borderWidth = 0
        }
    }
}
