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

public protocol SettingsView: class {
    func render(interval: TimeInterval)
}

public final class SettingsPresenter {
    
    public weak var view: SettingsView?
    
    private let state: State
    
    public init(state: State) {
        self.state = state
        state.register(self)
    }
    
    public func refresh() {
        view?.render(interval: state.cooldownInterval)
    }
    
    public func update(interval: TimeInterval) {
        state.cooldownInterval = interval
    }
}

extension SettingsPresenter: StateObserver {
    
    public func cooldownIntervalUpdated(_ cooldownInterval: TimeInterval) {
        refresh()
    }
    
}
