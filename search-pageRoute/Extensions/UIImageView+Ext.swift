//
//  UIImageView+Extensions.swift
//  Leafora
//

import UIKit

extension UIImageView {

    /// Loads an image from a remote URL string or a local asset/SF Symbol name.
    /// - Handles Cloudinary URLs (https://...)
    /// - Falls back to UIImage(named:) for local assets
    /// - Falls back to UIImage(systemName:) for SF Symbols
    /// - Shows a placeholder if everything fails
    func configureImage(with string: String?) {
        guard let string = string, !string.isEmpty else {
            setPlaceholder()
            return
        }

        // ✅ Remote URL — download asynchronously
        if string.hasPrefix("http://") || string.hasPrefix("https://") {
            loadRemoteImage(from: string)
            return
        }

        // Local asset name
        if let img = UIImage(named: string) {
            self.image = img
            return
        }

        // SF Symbol name (e.g. "person.circle.fill")
        if let img = UIImage(systemName: string) {
            self.image = img
            return
        }

        // Nothing worked
        setPlaceholder()
    }

    // MARK: - Private Helpers

    private func loadRemoteImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            setPlaceholder()
            return
        }

        // Show placeholder while loading
        setPlaceholder()

        // Check in-memory cache first
        if let cached = ImageCache.shared.get(for: urlString) {
            self.image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil
            else { return }

            // Cache the raw image
            ImageCache.shared.set(image, for: urlString)

            // ✅ iOS 15+: Decode the heavy image on a background thread before touching the UI
            if #available(iOS 15.0, *) {
                image.prepareForDisplay { preparedImage in
                    DispatchQueue.main.async {
                        // Ensure the image belongs to the current URL in case cell was reused
                        self.image = preparedImage ?? image
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }

    private func setPlaceholder() {
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray3, .white])
        self.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
    }
}

// MARK: - Simple In-Memory Image Cache
// Prevents re-downloading the same image every time a cell reloads
final class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func get(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func set(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
