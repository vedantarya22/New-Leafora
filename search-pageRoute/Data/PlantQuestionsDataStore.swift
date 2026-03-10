//
//  DataStore.swift
//  PlantApp
//
//  Created by SDC-USER on 26/11/25.
//

import Foundation
class DataStore {
    var PlantSiteOptions = [PlantSiteOption(image: "bed.double.fill", site: "Bedroom"),
                            PlantSiteOption(image: "sofa.fill", site: "Living Room"),
                            PlantSiteOption(image: "shower.fill", site: "Bathroom"),
                            PlantSiteOption(image: "fireplace.fill", site: "Hall"),
                            PlantSiteOption(image: "fork.knife", site: "Kitchen"),
                            PlantSiteOption(image: "cup.and.saucer.fill", site: "Dining Area"),
                            
    
                            PlantSiteOption(image: "sun.max.fill", site: "Balcony"),
                            PlantSiteOption(image: "leaf.fill", site: "Garden"),
                            
                            PlantSiteOption(image: "tree.fill", site: "Terrace"),
                            
                            PlantSiteOption(image: "plus", site: "Custom Site")
    ]
    func getQues1button() -> [PlantSiteOption] {
        return PlantSiteOptions
    }
    
    
    
    
    var plantLightOptions: [PlantLightOption] = [
        PlantLightOption(image: "sun.max.fill",   light: "full_sunlight",          displayName: "Full Sun"),
        PlantLightOption(image: "cloud.sun.fill", light: "partial_sunlight",       displayName: "Part sun, part shade"),
        PlantLightOption(image: "cloud.fill",     light: "medium_light",           displayName: "Shade"),
        PlantLightOption(image: "moon.fill",      light: "low_light",              displayName: "Dark")
    ]
    func getPlantLightOptions() -> [PlantLightOption] {
        return plantLightOptions
    }
    
    var repottingOptions: [OptionItem] = [
        OptionItem(title: "Never/In nursery pot"),
        OptionItem(title: "Last 7 days"),
        OptionItem(title: "About 1 month ago"),
        OptionItem(title: "About 3–6 months ago"),
        OptionItem(title: "1 year ago or more")
    ]
    
    func getRepottingOptions() -> [OptionItem] {
        return repottingOptions
    }
    
    
    var wateringOptions: [OptionItem] = [
        OptionItem(title: "Today"),
        OptionItem(title: "Yesterday"),
        OptionItem(title: "3–4 days ago"),
        OptionItem(title: "About 1 week ago"),
        OptionItem(title: "2 weeks ago or more")
    ]
    
    func getWateringOptions() -> [OptionItem] {
        return wateringOptions
    }

    var fertilizingOptions: [OptionItem] = [
        OptionItem(title: "Today"),
        OptionItem(title: "Yesterday"),
        OptionItem(title: "About 1 week ago"),
        OptionItem(title: "About 1 month ago"),
        OptionItem(title: "Never")
    ]

    func getFertilizingOptions() -> [OptionItem] {
        return fertilizingOptions
    }

    var pruningOptions: [OptionItem] = [
        OptionItem(title: "Recently (last week)"),
        OptionItem(title: "About 1 month ago"),
        OptionItem(title: "About 3 months ago"),
        OptionItem(title: "6 months ago or more"),
        OptionItem(title: "Never pruned")
    ]

    func getPruningOptions() -> [OptionItem] {
        return pruningOptions
    }

}

var dataStore = DataStore()
