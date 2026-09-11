import Foundation

class StreakManager {
    static let shared = StreakManager()
    private init() {}
    
    // MARK: - UserDefaults Keys
    private let kLastActiveDate = "streak_last_active_date"
    private let kCurrentStreak  = "streak_current_count"
    private let kLongestStreak  = "streak_longest_count"
    private let kLoggedDates    = "streak_logged_dates"
    
    private let calendar = Calendar.current
    private let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    // MARK: - Public Properties
    var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: kCurrentStreak) }
        set { UserDefaults.standard.set(newValue, forKey: kCurrentStreak) }
    }
    
    var longestStreak: Int {
        get { UserDefaults.standard.integer(forKey: kLongestStreak) }
        set { UserDefaults.standard.set(newValue, forKey: kLongestStreak) }
    }
    
    // MARK: - Record Activity (call on app open / care task completion)
    func recordActivity() {
        let todayStr = isoFormatter.string(from: Date())
        
        // Already recorded today
        if lastActiveDateString == todayStr { return }
        
        let wasYesterday = isYesterday(lastActiveDateString)
        
        if wasYesterday {
            currentStreak += 1
        } else {
            // streak broken — reset
            currentStreak = 1
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastActiveDateString = todayStr
        appendLoggedDate(todayStr)
    }
    
    // MARK: - Query API
    func wasActive(on date: Date) -> Bool {
        let str = isoFormatter.string(from: date)
        return loggedDateStrings.contains(str)
    }
    
    func loggedDates() -> [Date] {
        return loggedDateStrings.compactMap { isoFormatter.date(from: $0) }
    }
    
    // MARK: - Private Helpers
    private var lastActiveDateString: String? {
        get { UserDefaults.standard.string(forKey: kLastActiveDate) }
        set { UserDefaults.standard.set(newValue, forKey: kLastActiveDate) }
    }
    
    private var loggedDateStrings: [String] {
        get { UserDefaults.standard.stringArray(forKey: kLoggedDates) ?? [] }
    }
    
    private func appendLoggedDate(_ str: String) {
        var dates = loggedDateStrings
        if !dates.contains(str) {
            dates.append(str)
            UserDefaults.standard.set(dates, forKey: kLoggedDates)
        }
    }
    
    private func isYesterday(_ dateString: String?) -> Bool {
        guard let str = dateString, let date = isoFormatter.date(from: str) else { return false }
        return calendar.isDateInYesterday(date)
    }
}
