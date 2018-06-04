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

public struct IntervalOption {
    public let title: String
    public let action: () -> Void
}

public protocol CooldownView: class {
    func render(timeRemaining: String, backgroundColor: UIColor)
    func presentIntervalOptions(_ options: [IntervalOption])
    func presentSettings()
    func issueRedZoneWarning()
}

public class CooldownPresenter {
    
    public weak var view: CooldownView?
    
    public init() {}
    
    public func refresh() {
        let interval = max(State.shared.cooldown.target.timeIntervalSinceNow, 0)
        let timeRemaining = DateComponentsFormatter.cooldownFormatter.string(from: interval)!
        
        let backgroundColor: UIColor
        let percent = min(interval / State.shared.cooldownInterval / 3, 1)
        if percent <= 0.5 {
            backgroundColor = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            backgroundColor = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
        
        view?.render(timeRemaining: timeRemaining, backgroundColor: backgroundColor)
    }
    
    public func incrementCooldown(multipliedBy multiplier: Double = 1) {
        bumpCooldown(multipliedBy: multiplier)
    }
    
    public func decrementCooldown() {
        bumpCooldown(multipliedBy: -1)
    }
    
    private func bumpCooldown(multipliedBy multiplier: Double) {
        State.shared.cooldown += Cooldown(created: Date(), remaining: State.shared.cooldownInterval * multiplier)
        refresh()
        
        let interval = max(State.shared.cooldown.target.timeIntervalSinceNow, 0)
        let percent = interval / State.shared.cooldownInterval / 3
        if percent >= 1 && multiplier > 0 {
            view?.issueRedZoneWarning()
        }
    }
    
    public func loadIntervalOptions() {
        let formatter = DateComponentsFormatter.cooldownFormatter
        
        var options = [2.0, 1.5, 0.5]
            .map { multiplier in
                IntervalOption(
                    title: "+\(formatter.string(from: State.shared.cooldownInterval * multiplier)!)",
                    action: { self.bumpCooldown(multipliedBy: multiplier) }
                )
        }
        
        options.append(IntervalOption(title: "Edit Cooldown Interval...", action: { self.view?.presentSettings() }))
        view?.presentIntervalOptions(options)
    }
    
}
