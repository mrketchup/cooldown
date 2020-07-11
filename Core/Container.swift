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

open class Container {
    public let state: State
    public let watchService: WatchService
    public func cooldownViewModel() -> CooldownViewModel { CooldownViewModel(state: state) }
    public func settingsViewModel() -> SettingsViewModel { SettingsViewModel(state: state) }
    
    #if !os(watchOS)
    public let notificationService: NotificationService
    #endif
    
    public init(state: State) {
        self.watchService = WatchService(state: state)
        
        #if !os(watchOS)
        self.notificationService = NotificationService(state: state)
        #endif
        
        self.state = state
    }
    
    public convenience init() {
        self.init(state: State())
    }
}
