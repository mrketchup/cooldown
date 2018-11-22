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

import Foundation

public struct Shortcut {
    public let title: String
    public let multiplier: Double
}

public protocol SettingsView: class {
    func render(interval: TimeInterval)
    func updateAppShortcuts(_ shortcuts: [Shortcut])
}

public class SettingsPresenter {
    
    public weak var view: SettingsView?
    
    public init() {
        WatchService.shared.activate()
    }
    
    public func refresh() {
        view?.render(interval: State.shared.cooldownInterval)
    }
    
    public func update(interval: TimeInterval) {
        State.shared.cooldownInterval = interval
        WatchService.shared.stateUpdated(State.shared)
        
        let formatter = DateComponentsFormatter.cooldownFormatter
        let shortcuts = [2.0, 1.5, 0.5].map { multiplier in
            Shortcut(
                title: "Add \(formatter.string(from: State.shared.cooldownInterval * multiplier)!)",
                multiplier: multiplier
            )
        }
        
        view?.updateAppShortcuts(shortcuts)
    }
}