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

public final class NotificationService: NSObject {
    
    private let state: State
    
    init(state: State) {
        self.state = state
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .alert])
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        
        guard let multiplier = Double(response.actionIdentifier) else { return }
        state.cooldown += Cooldown(created: Date(), remaining: state.cooldownInterval * multiplier)
    }
    
}

extension NotificationService: StateObserver {
    
    public func cooldownUpdated(_ cooldown: Cooldown) {
        guard cooldown.target > Date() else { return }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted, let error = error {
                print(error)
                return
            }
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
            let content = UNMutableNotificationContent()
            content.categoryIdentifier = "cooldown_complete"
            content.title = "Cooldown complete"
            content.body = "Time elapsed: \(DateComponentsFormatter.notificationFormatter.string(from: cooldown.remaining) ?? "???")"
            content.sound = UNNotificationSound(named: UNNotificationSoundName("ding.wav"))
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: cooldown.remaining, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error { print(error) }
            }
        }
    }
    
    public func cooldownIntervalUpdated(_ cooldownInterval: TimeInterval) {
        let formatter = DateComponentsFormatter.cooldownFormatter
        
        let actions =  [2.0, 1.5, 1.0, 0.5].map { multiplier in
            UNNotificationAction(
                identifier: "\(multiplier)",
                title: "+\(formatter.string(from: cooldownInterval * multiplier)!)",
                options: []
            )
        }
        
        let category = UNNotificationCategory(identifier: "cooldown_complete", actions: actions, intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
}
