//  SceneDelegate.swift


import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var isLoadingData = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }

        let win = UIWindow(windowScene: ws)
        self.window = win

        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

        if !hasSeenOnboarding {
            print("First launch, showing onboarding")
            let sb = UIStoryboard(name: "onboarding", bundle: nil)
            win.rootViewController = sb.instantiateInitialViewController()

        } else if KeychainManager.shared.getToken() != nil,
                  KeychainManager.shared.getUserId() != nil {
            print("Token found, userId: \(UserSession.shared.currentLoggedInUserID)")
            let sb = UIStoryboard(name: "Main", bundle: nil)
            win.rootViewController = sb.instantiateInitialViewController()
            loadAppData()

        } else {
            print("No token, showing login")
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = sb.instantiateViewController(withIdentifier: "loginViewController")
            let navVC   = UINavigationController(rootViewController: loginVC)
            navVC.isNavigationBarHidden = true
            win.rootViewController = navVC
        }

        win.makeKeyAndVisible()
    }

    // MARK: - Load App Data
    // Called after login/signup AND on cold launch when token exists.
    func loadAppData() {
        guard !isLoadingData else {
            print("Data load already in progress, skipping")
            return
        }
        isLoadingData = true
        print("Starting app data load...")

        let userId = UserSession.shared.currentLoggedInUserID

        // 1. Current user profile
        UserSession.shared.fetchCurrentUser { user in
            if let user = user {
                print("Current user loaded: \(user.username)")
            }
        }

        // 2. Connect socket — server will flush offline messages on "register"
        ChatSocketManager.shared.connect(userId: userId)

        // 3. E2EE setup — generate key pair if this is first launch,
        //    then always register the public key (idempotent on the server).
        //    getOrCreatePrivateKey reads from Keychain or generates and stores a new key.
        _ = E2EEManager.shared.getOrCreatePrivateKey(for: userId)
        ChatManager.shared.registerPublicKey { success in
            print("E2EE public key registered: \(success)")
        }

        // 4. Plant catalogue
        PlantCatalogueCache.shared.getPlants { plants in
            print("Loaded \(plants.count) catalogue plants")
        }

        // 5. User's plants
        NetworkManager.shared.fetchUserPlants { [weak self] userPlants in
            guard let userPlants = userPlants else {
                print("Failed to load user plants")
                self?.isLoadingData = false
                return
            }
            PlantStore.shared.setPlants(userPlants)
            print("Loaded \(userPlants.count) user plants from MongoDB")
            PlantNotificationManager.shared.scheduleAllCareNotificationsDebounced()
            self?.isLoadingData = false
        }

        // 6. Sites
        NetworkManager.shared.getUserSites { sites in
            guard let sites = sites else { print("Failed to load sites"); return }
            SiteStore.shared.setSites(sites)
            print("Loaded \(sites.count) sites from MongoDB")
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    func sceneDidBecomeActive(_ scene: UIScene)    {}
    func sceneWillResignActive(_ scene: UIScene)   {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
