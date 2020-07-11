//
// Copyright © 2020 Matt Jones. All rights reserved.
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
import Combine

public typealias Event = PassthroughSubject<Void, Never>

public struct IntervalOption {
    public enum OptionType { case bump, edit }
    public let title: String
    public let action: () -> Void
    public let optionType: OptionType
}

public final class CooldownViewModel: StateObserver {
    @Published public private(set) var timeRemaining = "---"
    @Published public private(set) var targetDate: Date = .distantPast
    @Published public private(set) var primaryColor: UIColor = .cooldownGreen
    @Published public private(set) var intervalOptions: [IntervalOption] = []
    public let presentSettings = Event()
    public let redZoneWarning = Event()
    
    private let state: State
    
    public init(state: State) {
        self.state = state
        state.register(self)
    }
    
    public func refresh() {
        let interval = max(state.cooldown.target.timeIntervalSinceNow, 0)
        
        let percent = min(interval / state.cooldownInterval / 3, 1)
        if percent <= 0.5 {
            primaryColor = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            primaryColor = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
        
        timeRemaining = DateComponentsFormatter.cooldownFormatter.string(from: interval)!
        targetDate = state.cooldown.target
    }
    
    public func incrementCooldown() {
        bumpCooldown(multipliedBy: 1)
    }
    
    public func decrementCooldown() {
        bumpCooldown(multipliedBy: -1)
    }
    
    private func bumpCooldown(multipliedBy multiplier: Double) {
        state.cooldown += Cooldown(created: Date(), remaining: state.cooldownInterval * multiplier)
        
        let interval = max(state.cooldown.target.timeIntervalSinceNow, 0)
        let percent = interval / state.cooldownInterval / 3
        if percent >= 1 && multiplier > 0 {
            redZoneWarning.send()
        }
    }
    
    public func stateUpdated(_ state: State) {
        refresh()
    }
    
    public func cooldownIntervalUpdated(_ cooldownInterval: TimeInterval) {
        let formatter = DateComponentsFormatter.cooldownFormatter

        #if os(watchOS)
        let prefix = ""
        #else
        let prefix = "+"
        #endif
        
        var options = [2.0, 1.5, 0.5]
            .map { multiplier in
                (
                    title: "\(prefix)\(formatter.string(from: cooldownInterval * multiplier)!)",
                    action: { [weak self] in self?.bumpCooldown(multipliedBy: multiplier) }
                )
            }
            .map { IntervalOption(title: $0.title, action: $0.action, optionType: .bump) }
        
        #if os(watchOS)
        let title = "Edit Interval"
        #else
        let title = "Edit Cooldown Interval..."
        #endif
        options.append(IntervalOption(title: title, action: { [weak self] in self?.presentSettings.send() }, optionType: .edit))
        intervalOptions = options
    }
}
