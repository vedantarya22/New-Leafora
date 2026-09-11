//
//  AddPlantQuestion.swift
//  search-pageRoute
//

import Foundation

enum AddPlantQuestionType {
    case picker      // Quantity — UIPickerView
    case textOptions  // Repot / Water / Pruning / Fertilizing — PlantRepotCollectionViewCell text-only
}

struct AddPlantQuestion {
    let id: String
    let questionText: String
    let type: AddPlantQuestionType
    let options: [String]        // option display labels
    let optionKeys: [String]     // machine keys (e.g. "full_sunlight") — same order as options
}

// MARK: - Build question list from DataStore

extension AddPlantQuestion {

    /// Builds the ordered list of questions for the AddPlant questionnaire.
    /// This replaces the separate VCs while preserving exact same options.
    static func buildQuestions() -> [AddPlantQuestion] {
        let ds = dataStore

        // Q1: Quantity — handled with a UIPickerView, no options needed
        let quantity = AddPlantQuestion(
            id: "quantity",
            questionText: "How many of this plant are you adding?",
            type: .picker,
            options: [],
            optionKeys: []
        )

        // Q2: Repotting
        let repotOpts = ds.getRepottingOptions()
        let repotting = AddPlantQuestion(
            id: "repotting",
            questionText: "When was this plant last repotted?",
            type: .textOptions,
            options: repotOpts.map { $0.title },
            optionKeys: repotOpts.map { $0.title }
        )

        // Q3: Watering
        let waterOpts = ds.getWateringOptions()
        let watering = AddPlantQuestion(
            id: "watering",
            questionText: "When did you last water this plant?",
            type: .textOptions,
            options: waterOpts.map { $0.title },
            optionKeys: waterOpts.map { $0.title }
        )

        // Q4: Pruning
        let pruneOpts = ds.getPruningOptions()
        let pruning = AddPlantQuestion(
            id: "pruning",
            questionText: "When did you last prune this plant?",
            type: .textOptions,
            options: pruneOpts.map { $0.title },
            optionKeys: pruneOpts.map { $0.title }
        )

        // Q5: Fertilizing
        let fertOpts = ds.getFertilizingOptions()
        let fertilizing = AddPlantQuestion(
            id: "fertilizing",
            questionText: "When did you last fertilize this plant?",
            type: .textOptions,
            options: fertOpts.map { $0.title },
            optionKeys: fertOpts.map { $0.title }
        )

        return [quantity, repotting, watering, pruning, fertilizing]
    }
}
