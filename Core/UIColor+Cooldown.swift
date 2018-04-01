//
// Copyright © 2018 Matt Jones. All rights reserved.
//
// This file is part of Cooldown.
//
// Cooldown is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Cooldown is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cooldown.  If not, see <http://www.gnu.org/licenses/>.
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
