//
//  OnboardingModels.swift
//  search-pageRoute
//
//  Created by SDC-USER on 06/02/26.
//

import Foundation

struct OnboardingResponse: Decodable {
    let questions: [OnboardingQuestion]
}

struct OnboardingQuestion: Decodable {
    let id: String
    let question: String
    let options: [QuestionOption]
}

struct QuestionOption: Decodable {
    let id: String
    let label: String
}
