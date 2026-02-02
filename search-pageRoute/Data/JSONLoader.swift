//
//  JSONLoader.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import Foundation

class JSONLoader {
    static func loadPlants(from filename: String = "plants") -> [Plant] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let plantData = try decoder.decode(PlantData.self, from: data)
            return plantData.plants
        } catch {
            print("Error loading JSON: \(error)")
            return []
        }
    }
    
    
    // MARK: - Load Categories (Static)
        static func fetchCategories() -> [Category] {
            guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
                print("JSON file not found: categories")
                return []
            }

            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(CategoryResponse.self, from: data)
                return response.categories
            } catch {
                print("Error loading Categories JSON: \(error)")
                return []
            }
        }
    }

    // MARK: - Helper Structs
    struct CategoryResponse: Decodable {
        let categories: [Category]
    }
    
    
    

