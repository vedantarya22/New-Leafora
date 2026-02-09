//
//  InsightsModel.swift
//  search-pageRoute
//
//  Created by SDC-USER on 04/02/26.
//

import Foundation

enum InsightLevel {
    case warning
    case critical
    case good

    var priority: Int {
        switch self {
        case .good: return 0
        case .warning: return 1
        case .critical: return 2
        }
    }
}

struct GardenInsight: Identifiable {
    let id = UUID()
    let icon: String
    let message: String
    let level: InsightLevel
}
