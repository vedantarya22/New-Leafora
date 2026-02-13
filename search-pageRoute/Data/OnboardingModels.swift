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

struct OnboardingQuestion: Decodable, Hashable {
    let id: String
    let question: String
    let options: [QuestionOption]
}

struct QuestionOption: Decodable, Hashable {
    let id: String
    let label: String
}

struct OnboardingSlide {
    let title: String
    let description: String
    let imageName: String
}
