//
//  AppDelegate.swift
//  search-pageRoute
//
//  Created by SDC-USER on 27/01/26.
//

import UIKit
import UserNotifications
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // MARK: - Google Sign-In Configuration
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: "335696652565-4j9uavu2klq1302nhrjidsl9gjehv1i1.apps.googleusercontent.com"
        )

        // Request notification permission
        PlantNotificationManager.shared.requestPermission()

        // Allow notifications to show while app is in foreground
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: - Google Sign-In URL Handler
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: - Foreground Notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner even when app is open
        completionHandler([.banner, .list, .sound])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
