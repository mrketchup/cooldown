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

import WatchKit
import Combine
import Core_watchOS

final class InterfaceController: WKInterfaceController {
    @IBOutlet private var interfaceGroup: WKInterfaceGroup!
    @IBOutlet private var cooldownTimer: WKInterfaceTimer!
    private weak var timer: Timer?
    private let viewModel = ExtensionDelegate.container.cooldownViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var actions: [() -> Void] = []
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    override func willActivate() {
        super.willActivate()
        let timer = Timer(timeInterval: 0.5, repeats: true) { [unowned self] _ in self.viewModel.refresh() }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        self.timer?.fire()
        
        viewModel.$primaryColor
            .sink { [interfaceGroup] in interfaceGroup?.setBackgroundColor($0) }
            .store(in: &cancellables)
        
        viewModel.$targetDate
            .sink { [cooldownTimer] target in
                if target > Date() {
                    cooldownTimer?.setDate(target)
                    cooldownTimer?.start()
                } else {
                    cooldownTimer?.setDate(Date())
                    cooldownTimer?.stop()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$intervalOptions
            .sink { [unowned self] in self.updateIntervalOptions($0) }
            .store(in: &cancellables)
        
        viewModel.presentSettings
            .sink { [unowned self] in self.presentController(withName: "SettingsInterfaceController", context: nil) }
            .store(in: &cancellables)
        
        viewModel.redZoneWarning
            .sink { WKInterfaceDevice.current().play(.failure) }
            .store(in: &cancellables)
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        cooldownTimer.stop()
        timer?.invalidate()
    }
    
    @objc private func action1ButtonPressed() { actions[0]() }
    @objc private func action2ButtonPressed() { actions[1]() }
    @objc private func action3ButtonPressed() { actions[2]() }
    @objc private func action4ButtonPressed() { actions[3]() }
    
    @IBAction private func swipeDown(_ sender: WKSwipeGestureRecognizer) {
        viewModel.decrementCooldown()
    }
    
    @IBAction private func addButtonPressed(_ sender: WKInterfaceButton) {
        viewModel.incrementCooldown()
    }
    
    private func updateIntervalOptions(_ options: [IntervalOption]) {
        clearAllMenuItems()
        actions = options.prefix(4).map { $0.action }
        
        let selectors = [
            #selector(action1ButtonPressed),
            #selector(action2ButtonPressed),
            #selector(action3ButtonPressed),
            #selector(action4ButtonPressed)
        ]
        
        for index in 0..<4 {
            let icon: WKMenuItemIcon
            switch options[index].optionType {
            case .bump: icon = .add
            case .edit: icon = .more
            }
            
            addMenuItem(with: icon, title: options[index].title, action: selectors[index])
        }
    }
}
