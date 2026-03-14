//
//  User.swift
//  Leafora
//

import Foundation

class User: Codable {
    let id: String
    var name: String
    var username: String
    var profileImageString: String?
    var email: String?
    var phoneNumber: String?
    var dateOfBirth: String?

    // ✅ Populated by backend via getUserById (Option B) or own profile from PlantStore
    var plantCount: Int

    init(id: String,
         name: String,
         username: String,
         profileImageString: String?,
         plantCount: Int = 0,
         email: String? = nil,
         phoneNumber: String? = nil,
         dateOfBirth: String? = nil) {
        self.id                 = id
        self.name               = name
        self.username           = username
        self.profileImageString = profileImageString
        self.plantCount         = plantCount
        self.email              = email
        self.phoneNumber        = phoneNumber
        self.dateOfBirth        = dateOfBirth
    }

    //  Custom decoder — plantCount defaults to 0 if not in response
    required init(from decoder: Decoder) throws {
        let c               = try decoder.container(keyedBy: CodingKeys.self)
        id                  = try c.decode(String.self,           forKey: .id)
        name                = try c.decode(String.self,           forKey: .name)
        username            = try c.decode(String.self,           forKey: .username)
        profileImageString  = try c.decodeIfPresent(String.self,  forKey: .profileImageString)
        email               = try c.decodeIfPresent(String.self,  forKey: .email)
        phoneNumber         = try c.decodeIfPresent(String.self,  forKey: .phoneNumber)
        dateOfBirth         = try c.decodeIfPresent(String.self,  forKey: .dateOfBirth)
        plantCount          = try c.decodeIfPresent(Int.self,     forKey: .plantCount) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, username, profileImageString
        case email, phoneNumber, dateOfBirth, plantCount
    }

    var handle: String { "@\(username)" }
    var searchSubtitle: String { "\(plantCount) Plants" }

    func copy() -> User {
        User(id: id, name: name, username: username,
             profileImageString: profileImageString,
             plantCount: plantCount,
             email: email, phoneNumber: phoneNumber, dateOfBirth: dateOfBirth)
    }
}
