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

import UserNotifications

class NotificationService: NSObject {
    
    static let shared = NotificationService()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func scheduleNotification(for cooldown: Cooldown) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted, let error = error {
                print(error)
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Cooldown complete"
            content.body = "Time elapsed: \(DateComponentsFormatter.notificationFormatter.string(from: cooldown.remaining) ?? "???")"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("ding.wav"))

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: cooldown.target)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error { print(error) }
            }
        }
    }
    
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }
    
}
