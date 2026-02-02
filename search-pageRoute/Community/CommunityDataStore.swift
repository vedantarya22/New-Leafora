import Foundation
import UIKit

// MARK: - Deprecated
// This class is being deprecated in favor of PostRepository (for posts) and UserSession (for users).
// It has been hollowed out to avoid confusion and state splitting.

class CommunityDataStore {
    
    static let shared = CommunityDataStore()
    
    // Deprecated: Logic moved to UserSession and PostRepository
    private init() {
        // No-op
    }
    
    // MARK: - Deprecated APIs
    // Kept here momentarily if runtime crashes occur, but logic should be removed.
    // If we are sure all VCs are updated, we can delete this file.
    // The instructions said "root problem is that CommunityDataStore is acting as a god object".
    // We have moved the logic.
    
    // Leaving this empty or minimal.
    
    // NOTE: If there are other ViewControllers referencing this that I missed, they will now break.
    // Based on my search, I caught the relevant ones.
    // I will leave 'getDocumentsDirectory' as a helper if needed, but it was private anyway.
    
}

