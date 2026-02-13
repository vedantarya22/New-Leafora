//
//  CareCountdown.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation
import UIKit

struct CareStatus {
    let text: String
    let color: UIColor
    let isOverdue: Bool
}

struct CareCountdown {

    static func status(
        lastDate: Date?,
        frequencyDays: Int,
        taskName: String
    ) -> CareStatus {

        let daysPassed = daysSince(lastDate)
        let remaining = frequencyDays - daysPassed

        if remaining > 0 {
            return CareStatus(
                text: "Next \(taskName) in \(remaining) days",
                color: .systemGreen,
                isOverdue: false
            )
        } else {
            return CareStatus(
                text: "\(taskName) overdue by \(abs(remaining)) days",
                color: .systemRed,
                isOverdue: true
            )
        }
    }

    private static func daysSince(_ date: Date?) -> Int {
        guard let date else { return Int.max }
        return Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? Int.max
    }
}
