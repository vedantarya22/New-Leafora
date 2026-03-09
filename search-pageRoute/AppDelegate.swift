//
//  AppDelegate.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
           
//        UIViewController.swizzlePresent()
        // Override point for customization after application launch.
        setupTestUser()
        return true
    }
    
    
    // ✅ Temp until auth — creates or reuses test user
       private func setupTestUser() {
           
           // check if we already saved a userId locally
           if let savedId = UserDefaults.standard.string(forKey: "currentUserId") {
               NetworkManager.shared.currentUserId = savedId
               print("✅ Loaded userId from local: \(savedId)")
               loadAppData()
               return
           }
           
           // first launch — create test user
           NetworkManager.shared.createUser(
               name: "Vedant Arya",
               username: "vedantarya22",
               email: "vedant@test.com"
           ) { userId in
               guard let userId = userId else {
                   print("❌ Failed to create user")
                   return
               }
               // save locally so we don't create duplicates on relaunch
               UserDefaults.standard.set(userId, forKey: "currentUserId")
               NetworkManager.shared.currentUserId = userId
               print("✅ Test user created: \(userId)")
               self.loadAppData()
           }
       }
    
    private func loadAppData() {
          
          // ✅ Load plant catalogue from MongoDB (replaces JSONLoader)
          NetworkManager.shared.fetchAllPlants { plants in
              guard let plants = plants else {
                  print("❌ Failed to load plants")
                  return
              }
              PlantCatalogueCache.shared.setPlants(plants)
              print("✅ Loaded \(plants.count) plants from backend")
          }
          
          // ✅ Load user's garden plants
          NetworkManager.shared.fetchUserPlants { userPlants in
              guard let userPlants = userPlants else {
                  print("❌ Failed to load user plants")
                  return
              }
              PlantStore.shared.setPlants(userPlants)  
              print("✅ Loaded \(userPlants.count) user plants")
          }
          
          // ✅ Load user's sites
          NetworkManager.shared.getUserSites { sites in
              guard let sites = sites else {
                  print("❌ Failed to load sites")
                  return
              }
              SiteStore.shared.setSites(sites)           // ✅ was .sites = sites
              print("✅ Loaded \(sites.count) sites")
          }
      }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

