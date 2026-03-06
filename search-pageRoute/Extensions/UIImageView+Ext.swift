//
//  UIImageView+Ext.swift
//  garden_app
//
//  Created by SDC-USER on 08/12/25.
//

import Foundation
import UIKit

extension UIImageView {
    
    // Call this function instead of setting .image directly
    func configureImage(with name: String) {
        // 0. Empty string → neutral grey placeholder (no photo set yet)
        guard !name.isEmpty else {
            self.image = UIImage(systemName: "person.circle.fill")
            self.tintColor = .systemGray3
            self.contentMode = .scaleAspectFit
            return
        }

        // 1. Check if it's a File stored in Documents (New Posts)
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
        if let savedImage = UIImage(contentsOfFile: filename.path) {
            self.image = savedImage
            self.contentMode = .scaleAspectFill
            self.clipsToBounds = true
            return
        }

        // 2. Is it a System Symbol? Always use grey tint to avoid inherited blue
        if let systemImage = UIImage(systemName: name) {
            self.image = systemImage
            self.tintColor = .systemGray3
            self.contentMode = .scaleAspectFit
            return
        }

        // 3. Is it a Local Asset? (e.g. "plant_vedant")
        if let assetImage = UIImage(named: name) {
            self.image = assetImage
            self.contentMode = .scaleAspectFill
            self.clipsToBounds = true
            return
        }

        // 4. Fallback
        self.image = UIImage(systemName: "person.circle.fill")
        self.tintColor = .systemGray3
    }
}
