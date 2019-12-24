//
// Copyright © 2019 Matt Jones. All rights reserved.
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
import Core_iOS

final class ShortcutService: NSObject {
    
    private let application: UIApplication
    private let formatter: DateComponentsFormatter
    
    init(application: UIApplication, formatter: DateComponentsFormatter) {
        self.application = application
        self.formatter = formatter
    }
    
}

extension ShortcutService: StateObserver {
    
    func cooldownIntervalUpdated(_ cooldownInterval: TimeInterval) {
        let formatter = DateComponentsFormatter.cooldownFormatter
        
        UIApplication.shared.shortcutItems =  [2.0, 1.5, 0.5].map { multiplier in
            UIApplicationShortcutItem(
                type: "bump",
                localizedTitle: formatter.string(from: cooldownInterval * multiplier)!,
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(type: .add),
                userInfo: ["multiplier": NSNumber(value: multiplier)]
            )
        }
    }
    
}
