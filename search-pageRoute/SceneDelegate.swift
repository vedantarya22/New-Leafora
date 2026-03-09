import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }

        let win = UIWindow(windowScene: ws)
        self.window = win

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

        if !hasSeenOnboarding {
            print("👋 First launch, showing onboarding")
            let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
            win.rootViewController = storyboard.instantiateInitialViewController()

        } else if let token = KeychainManager.shared.getToken(),
                  let userId = KeychainManager.shared.getUserId() {
            NetworkManager.shared.currentUserId = userId
            print("✅ Token found, going to home")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            win.rootViewController = storyboard.instantiateInitialViewController()
            loadAppData()

        } else {
            print("⚠️ No token, showing login")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            win.rootViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController")
        }

        win.makeKeyAndVisible()
    }

    // MARK: - Load App Data
    func loadAppData() {
        // ✅ Load catalogue
        PlantCatalogueCache.shared.getPlants { plants in
            print("✅ Loaded \(plants.count) catalogue plants")
        }

        // ✅ Always replace local with MongoDB — prevents duplicates
        NetworkManager.shared.fetchUserPlants { userPlants in
            guard let userPlants = userPlants else {
                print("❌ Failed to load user plants")
                return
            }
            PlantStore.shared.setPlants(userPlants)
            print("✅ Loaded \(userPlants.count) user plants from MongoDB")
        }

        // ✅ Always replace local sites with MongoDB
        NetworkManager.shared.getUserSites { sites in
            guard let sites = sites else {
                print("❌ Failed to load sites")
                return
            }
            SiteStore.shared.setSites(sites)
            print("✅ Loaded \(sites.count) sites from MongoDB")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
