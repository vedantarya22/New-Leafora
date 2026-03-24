//
//  GoogleAuthManager.swift
//  Leafora
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit
import GoogleSignIn

class GoogleAuthManager {

    static let shared = GoogleAuthManager()
    private init() {}

    // MARK: - Sign In with Google
    // Call this from both LoginVC and SignUpVC
    func signIn(presenting viewController: UIViewController,
                completion: @escaping (_ success: Bool, _ message: String?) -> Void) {

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                print("❌ Google Sign-In error: \(error.localizedDescription)")
                completion(false, "Google Sign-In cancelled or failed")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(false, "Could not retrieve Google credentials")
                return
            }

            print("✅ Google token received, sending to backend...")

            // MARK: Send ID token to your backend
            NetworkManager.shared.googleAuth(idToken: idToken) { success, message in
                completion(success, message)
            }
        }
    }
}
