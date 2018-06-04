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
import WatchConnectivity
import Core_iOS

class SettingsViewController: UIViewController {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var cooldownDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            // Workaround for a UIDatePicker bug not firing the first value change event
            self.cooldownDatePicker.countDownDuration = State.shared.cooldownInterval
        }
    }
    
    @IBAction func cooldownDatePickerValueChanged(_ sender: UIDatePicker) {
        State.shared.cooldownInterval = TimeInterval(sender.countDownDuration)
        do {
            try WCSession.default.updateApplicationContext(State.shared.appContext)
        } catch {
            print(error)
        }
    }
    
    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
