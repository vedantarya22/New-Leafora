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

        } else if KeychainManager.shared.getToken() != nil,
                  KeychainManager.shared.getUserId() != nil {
            // ✅ Token exists — identity is read from Keychain by UserSession automatically.
            //    No need to set currentUserId anywhere.
            print("✅ Token found, userId: \(UserSession.shared.currentLoggedInUserID)")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            win.rootViewController = storyboard.instantiateInitialViewController()
            loadAppData()

        } else {
            print("⚠️ No token, showing login")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginViewController")
            let navVC = UINavigationController(rootViewController: loginVC)
            navVC.isNavigationBarHidden = true
            win.rootViewController = navVC
        }

        win.makeKeyAndVisible()
    }

    // MARK: - Load App Data
    // Called after login/signup (from those VCs) AND on cold launch when token exists.
    func loadAppData() {

        // 1. Current user profile — needed by PostRepository, NewPostVC, ProfileVC, etc.
        UserSession.shared.fetchCurrentUser { user in
            if let user = user {
                print("✅ Current user loaded: \(user.username)")
            } else {
                print("⚠️ Could not load current user profile")
            }
        }
        
        // Connect socket with logged-in user's ID

        ChatSocketManager.shared.connect(userId: UserSession.shared.currentLoggedInUserID)


        // 2. Plant catalogue
        PlantCatalogueCache.shared.getPlants { plants in
            print("✅ Loaded \(plants.count) catalogue plants")
        }

        // 3. User's plants — always replace local with MongoDB to prevent duplicates
        NetworkManager.shared.fetchUserPlants { userPlants in
            guard let userPlants = userPlants else {
                print("❌ Failed to load user plants")
                return
            }
            PlantStore.shared.setPlants(userPlants)
            print("✅ Loaded \(userPlants.count) user plants from MongoDB")
        }

        // 4. User's sites — always replace local with MongoDB
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
