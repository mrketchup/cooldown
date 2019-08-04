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

import UIKit
import UserNotifications
import UserNotificationsUI
import Core_iOS

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var cooldownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let interval = State.shared.cooldown.remaining
        cooldownLabel.text = DateComponentsFormatter.cooldownFormatter.string(from: interval)
        
        let percent = min(interval / State.shared.cooldownInterval / 3, 1)
        if percent <= 0.5 {
            view.backgroundColor = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            view.backgroundColor = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
    }
    
    func didReceive(_ notification: UNNotification) {}

}
