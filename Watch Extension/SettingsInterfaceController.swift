//
//  SettingsInterfaceController.swift
//  Watch Extension
//
//  Created by Matt Jones on 10/27/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity
import Core_watchOS


class SettingsInterfaceController: WKInterfaceController {
    
    @IBOutlet var hourPicker: WKInterfacePicker!
    @IBOutlet var minutePicker: WKInterfacePicker!
    var hours = Int(State.shared.cooldownInterval / 3600)
    var minutes = Int(State.shared.cooldownInterval / 60) % 60
    var pendingCorrection: DispatchWorkItem?

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
        
        hourPicker.setSelectedItemIndex(hours)
        minutePicker.setSelectedItemIndex(minutes)
    }
    
    override func willDisappear() {
        super.willDisappear()
        State.shared.cooldownInterval = TimeInterval(3600 * hours + 60 * minutes)
        do { try WCSession.default.updateApplicationContext(State.shared.appContext) }
        catch { print(error) }
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
