//
//  UIColor+AppTheme.swift.swift
//  search-pageRoute
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

extension UIColor {
    
    // MARK: - Brand Solid Color
    static let brandGreen = UIColor(
        red: 55.0/255.0,
        green: 125.0/255.0,
        blue: 41.0/255.0,
        alpha: 1.0
    )
}

extension CAGradientLayer {
    
    // MARK: - Background Green Gradient
    static func backgroundGreen() -> CAGradientLayer {
        
        let gradient = CAGradientLayer()
        
        let topColor = UIColor(
            red: 0.96,
            green: 0.98,
            blue: 0.96,
            alpha: 1.0
        ).cgColor
        
        let bottomColor = UIColor(
            red: 0.88,
            green: 0.94,
            blue: 0.89,
            alpha: 1.0
        ).cgColor
        
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        return gradient
    }
}
