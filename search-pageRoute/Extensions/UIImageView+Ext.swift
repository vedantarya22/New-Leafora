////
////  UIImageView+Ext.swift
////  garden_app
////
////  Created by SDC-USER on 08/12/25.
////
//
//import Foundation
//import UIKit
//
//extension UIImageView {
//    
//    // Call this function instead of setting .image directly
//    func configureImage(with name: String) {
//        // 1. Check if it's a File stored in Documents (New Posts)
//        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(name)
//        if let savedImage = UIImage(contentsOfFile: filename.path) {
//            self.image = savedImage
//            self.contentMode = .scaleAspectFill
//            self.clipsToBounds = true
//            return
//        }
//        
//        // 2. Is it a System Symbol? (e.g. "person.circle")
//        if let systemImage = UIImage(systemName: name) {
//            self.image = systemImage
//            self.contentMode = .scaleAspectFit
//            return
//        }
//        
//        // 3. Is it a Local Asset? (e.g. "plant_vedant")
//        if let assetImage = UIImage(named: name) {
//            self.image = assetImage
//            self.contentMode = .scaleAspectFill
//            self.clipsToBounds = true
//            return
//        }
//        
//        // 4. Fallback (If nothing works, show a gray square)
//        self.image = UIImage(systemName: "photo")
//        //        self.backgroundColor = .systemGray6
//    }
//}
