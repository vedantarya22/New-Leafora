////
////  SiteStore.swift
////  PlantApp
////
////  Created by SDC-USER on 12/12/25.
////
//
//import Foundation
//import UIKit
//internal import Combine
//
//class SiteStore: ObservableObject {
//    
//    
//    static let shared = SiteStore()
//    
//    @Published var sites: [MyGardenSite] = [] {
//        didSet { saveSites() }
//    }
//    
//    private let key = "savedSites"
//    
//   private init() {
//        loadSites()
//    }
//    
//    // MARK: Add site (called from questionnaire)
//    func addSite(name: String, icon: String) {
//        
//        // check if site already exists → avoid duplicates
//        if sites.contains(where: { $0.name == name }) {
//            return
//        }
//        
//        let newSite = MyGardenSite(
//            id: UUID(),
//            name: name,
////            cardColor: UIColorCodable(color),
//            icon: icon,
//            plantCount: 0 // start with 0 plants
//        )
//        
//        sites.append(newSite)
//    }
//    
//    // MARK: Add or update plant count
//      func addPlants(to siteName: String, count: Int) {
//          if let index = sites.firstIndex(where: { $0.name.lowercased() == siteName.lowercased() }) {
//              sites[index].plantCount += count
//              return
//          }
//
//          let newSite = MyGardenSite(
//              id: UUID(),
//              name: siteName,
////              cardColor: UIColorCodable(.systemGreen),
//              icon: "leaf",
//              plantCount: count
//          )
//
//          sites.append(newSite)
//      }
//    
//    
//    
//    // MARK: Save
//    private func saveSites() {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(sites) {
//            UserDefaults.standard.set(encoded, forKey: key)
//        }
//    }
//    
//    
//    
//    // MARK: Load
//    private func loadSites() {
//        if let data = UserDefaults.standard.data(forKey: key),
//           let decoded = try? JSONDecoder().decode([MyGardenSite].self, from: data) {
//            self.sites = decoded
//        }
//    }
//}
