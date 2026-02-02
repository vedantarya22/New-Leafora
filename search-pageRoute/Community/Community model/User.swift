//
//  User.swift
//  garden_app
//
//  Created by SDC-USER on 24/11/25.
//

import Foundation

class User: Codable {
    let id: String
    let name: String            // "Vedant Arya"
    let username: String                                     
    var profileImageString: String
    
    // Stats for Profile Page
    let plantCount: Int
    var personality: String?
    
    
    init(id: String, name: String, username: String, profileImageString: String, plantCount: Int) {
        self.id = id
        self.name = name
        self.username = username
        self.profileImageString = profileImageString
        self.plantCount = plantCount
    }
    
    // Helper for Profile Page Label ("@vedantarya.22")
    var handle: String {
        return "@\(username)"
    }
    
    // Helper for Search Page ("12 Plants | 5 Friends")
    var searchSubtitle: String {
        return "\(plantCount) Plants"
    }
}
