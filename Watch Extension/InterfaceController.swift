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
import WatchKit
import WatchConnectivity
import Core_watchOS

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var interfaceGroup: WKInterfaceGroup!
    @IBOutlet var cooldownTimer: WKInterfaceTimer!
    weak var timer: Timer?
    let presenter = CooldownPresenter()
    var actions: [() -> Void] = []
    
    override func willActivate() {
        super.willActivate()
        presenter.view = self
        presenter.loadIntervalOptions()
        
        let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        self.timer?.fire()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        cooldownTimer.stop()
        timer?.invalidate()
    }
    
    func stateChanged() {
        presenter.refresh()
        presenter.loadIntervalOptions()
    }
    
    @objc private func action1ButtonPressed() { actions[0]() }
    @objc private func action2ButtonPressed() { actions[1]() }
    @objc private func action3ButtonPressed() { actions[2]() }
    @objc private func action4ButtonPressed() { actions[3]() }
    
    @objc private func refresh() {
        presenter.refresh()
    }
    
    @IBAction private func swipeDown(_ sender: WKSwipeGestureRecognizer) {
        presenter.decrementCooldown()
        updateSession()
    }
    
    @IBAction private func addButtonPressed(_ sender: WKInterfaceButton) {
        presenter.incrementCooldown()
        updateSession()
    }
    
    private func updateSession() {
        do {
            try WCSession.default.updateApplicationContext(State.shared.appContext)
        } catch {
            print(error)
        }
    }
    
}

extension InterfaceController: CooldownView {
    
    func render(target: Date, backgroundColor: UIColor) {
        interfaceGroup.setBackgroundColor(backgroundColor)
        if target > Date() {
            cooldownTimer.setDate(target)
            cooldownTimer.start()
        } else {
            cooldownTimer.setDate(Date())
            cooldownTimer.stop()
        }
    }
    
    func updateIntervalOptions(_ options: [IntervalOption]) {
        clearAllMenuItems()
        actions = options.prefix(4).map { option in { option.action(); self.updateSession() } }
        
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
    
    func presentSettings() {
        presentController(withName: "SettingsInterfaceController", context: nil)
    }
    
    func issueRedZoneWarning() {
        WKInterfaceDevice.current().play(.notification)
    }
    
}
