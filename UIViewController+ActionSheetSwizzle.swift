import UIKit
import ObjectiveC

// MARK: - Auto Action Sheet Swizzle
// Add this file to your project. No other changes needed.
// Every UIAlertController(.actionSheet) will automatically become BotanicalActionSheet.

extension UIViewController {
    
    static func swizzlePresent() {
        let original = class_getInstanceMethod(UIViewController.self, #selector(present(_:animated:completion:)))
        let swizzled = class_getInstanceMethod(UIViewController.self, #selector(swizzled_present(_:animated:completion:)))
        if let original, let swizzled {
            method_exchangeImplementations(original, swizzled)
        }
    }
    
    @objc private func swizzled_present(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        // Only intercept UIAlertController with .actionSheet style
        guard let alert = viewController as? UIAlertController,
              alert.preferredStyle == .actionSheet else {
            swizzled_present(viewController, animated: animated, completion: completion)
            return
        }
        
        // Convert UIAlertActions to BotanicalActions
        let botanicalActions: [BotanicalAction] = alert.actions.map { action in
            BotanicalAction(
                title: action.title ?? "",
                style: {
                    switch action.style {
                    case .destructive: return .destructive
                    case .cancel:      return .cancel
                    default:           return .default
                    }
                }(),
                handler: {
                    action.accessibilityActivate() // triggers the action's handler
                }
            )
        }
        
        let sheet = BotanicalActionSheet(
            title: alert.title,
            message: alert.message,
            actions: botanicalActions
        )
        
        swizzled_present(sheet, animated: false, completion: completion)
    }
}
