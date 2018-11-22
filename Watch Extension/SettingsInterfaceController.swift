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
import Core_watchOS

class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var minutePicker: WKInterfacePicker!
    
    private let presenter = SettingsPresenter()
    
    var hours = 0
    var minutes = 0
    var pendingCorrection: DispatchWorkItem?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        presenter.view = self
        
        hourPicker.setItems((0..<24).map { hour -> WKPickerItem in
            let item = WKPickerItem()
            item.title = "\(hour)"
            return item
        })
        
        minutePicker.setItems((0..<60).map { hour -> WKPickerItem in
            let item = WKPickerItem()
            item.title = "\(hour)"
            return item
        })
        
        presenter.refresh()
    }
    
    override func willDisappear() {
        super.willDisappear()
        presenter.update(interval: TimeInterval(3600 * hours + 60 * minutes))
    }
    
    @IBAction func hourPickerAction(_ index: Int) {
        hours = index
        correctHoursAndMinutesIfNeeded()
    }
    
    @IBAction func minutePickerAction(_ index: Int) {
        minutes = index
        correctHoursAndMinutesIfNeeded()
    }
    
    func correctHoursAndMinutesIfNeeded() {
        pendingCorrection?.cancel()
        pendingCorrection = nil
        
        guard hours == 0 && minutes == 0 else { return }
        
        let item = DispatchWorkItem {
            self.minutePicker.setSelectedItemIndex(1)
            self.pendingCorrection = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: item)
        pendingCorrection = item
    }
    
}

extension SettingsInterfaceController: SettingsView {
    
    func render(interval: TimeInterval) {
        hours = Int(interval / 3600)
        minutes = Int(interval / 60) % 60
        hourPicker.setSelectedItemIndex(hours)
        minutePicker.setSelectedItemIndex(minutes)
    }
    
    func updateAppShortcuts(_ shortcuts: [Shortcut]) {}
    
}
