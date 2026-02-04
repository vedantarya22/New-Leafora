//
//  PlantQuestionSession.swift
//  PlantApp
//
//  Created by vedant on 03/01/26.
//
import Foundation

struct PlantQuestionSession {

    // injected once from PlantDetailViewController
    let plantId: String

    // 🔹 direct mappings (user choices)
    var siteName: String?
    var siteIcon: String?
    var plantCount: Int?
    var plantLight: String?
    var imageData: Data?

    // 🔹 answers shown to user
    var wateringAnswer: String?
    var repottingAnswer: String?

    // 🌱 smart timestamps (NEW — for reminders & insights)
    var lastWateredDate: Date?
    var lastRepottedDate: Date?
}




enum CareHistoryOption {
    case never
    case last7Days
    case oneMonth
    case threeToSixMonths
    case oneYearOrMore
}

func dateFromOption(_ option: CareHistoryOption) -> Date? {

    let calendar = Calendar.current
    let today = Date()

    switch option {

    case .never:
        return nil   // means never done → pending

    case .last7Days:
        return calendar.date(byAdding: .day, value: -7, to: today)

    case .oneMonth:
        return calendar.date(byAdding: .month, value: -1, to: today)

    case .threeToSixMonths:
        return calendar.date(byAdding: .month, value: -4, to: today) // average

    case .oneYearOrMore:
        return calendar.date(byAdding: .year, value: -1, to: today)
    }
}

func dateFromWateringOptionText(_ text: String) -> Date? {

    let today = Date()
    let cal = Calendar.current

    switch text {

    case "Today":
        return today

    case "Yesterday":
        return cal.date(byAdding: .day, value: -1, to: today)

    case "3–4 days ago":
        return cal.date(byAdding: .day, value: -4, to: today)

    case "About 1 week ago":
        return cal.date(byAdding: .day, value: -7, to: today)

    case "2 weeks ago or more":
        return cal.date(byAdding: .day, value: -14, to: today)

    default:
        return nil
    }
}


