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
    
    // swiftlint:disable identifier_name
    struct RGBA {
        var r: CGFloat
        var g: CGFloat
        var b: CGFloat
        var a: CGFloat
    }
    // swiftlint:enable identifier_name
    
    static let cooldownGreen = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
    static let cooldownYellow = UIColor(red: 1, green: 0.7, blue: 0, alpha: 1)
    static let cooldownRed = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
    
    var rgba: RGBA {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return RGBA(r: red, g: green, b: blue, a: alpha)
    }
    
    func blended(with color: UIColor, percent: CGFloat) -> UIColor {
        let rgba1 = rgba
        let rgba2 = color.rgba
        let red = rgba1.r * (1 - percent) + rgba2.r * percent
        let green = rgba1.g * (1 - percent) + rgba2.g * percent
        let blue = rgba1.b * (1 - percent) + rgba2.b * percent
        let alpha = rgba1.a * (1 - percent) + rgba2.a * percent
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
