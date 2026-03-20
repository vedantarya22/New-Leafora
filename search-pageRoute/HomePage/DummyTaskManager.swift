import Foundation

class DummyTaskManager {
    static let shared = DummyTaskManager()
    
    // Reset to true every time the app launches
    var showDummyUrgent: Bool = true
    var showDummyMissed: Bool = true
}// for dummy data in homescreen to show
