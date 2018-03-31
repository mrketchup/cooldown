//
//  UIColor+Cooldown.swift
//  Cooldown
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public static let cooldownGreen = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
    public static let cooldownYellow = UIColor(red: 1, green: 0.7, blue: 0, alpha: 1)
    public static let cooldownRed = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
    
    public var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    public func blended(with color: UIColor, percent: CGFloat) -> UIColor {
        let rgba1 = rgba
        let rgba2 = color.rgba
        let r = rgba1.r * (1 - percent) + rgba2.r * percent
        let g = rgba1.g * (1 - percent) + rgba2.g * percent
        let b = rgba1.b * (1 - percent) + rgba2.b * percent
        let a = rgba1.a * (1 - percent) + rgba2.a * percent
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}
