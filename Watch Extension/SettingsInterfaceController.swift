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

final class SettingsInterfaceController: WKInterfaceController {
    @IBOutlet private var hourPicker: WKInterfacePicker!
    @IBOutlet private var minutePicker: WKInterfacePicker!
    private let viewModel = Container.settingsViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private var hours = 0
    private var minutes = 0
    private var pendingCorrection: DispatchWorkItem?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
        
        viewModel.$cooldownInterval
            .map { Int($0 / 3600) }
            .sink { [unowned self] in
                self.hours = $0
                self.hourPicker.setSelectedItemIndex($0)
            }
            .store(in: &cancellables)
        
        viewModel.$cooldownInterval
            .map { Int($0 / 60) % 60 }
            .sink { [unowned self] in
                self.minutes = $0
                self.minutePicker.setSelectedItemIndex($0)
            }
            .store(in: &cancellables)
    }
    
    override func willDisappear() {
        super.willDisappear()
        pendingCorrection?.perform()
        pendingCorrection?.cancel()
        pendingCorrection = nil
        
        viewModel.update(interval: TimeInterval(3600 * hours + 60 * minutes))
    }
    
    @IBAction private func hourPickerAction(_ index: Int) {
        hours = index
        correctHoursAndMinutesIfNeeded()
    }
    
    @IBAction private func minutePickerAction(_ index: Int) {
        minutes = index
        correctHoursAndMinutesIfNeeded()
    }
    
    private func correctHoursAndMinutesIfNeeded() {
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
