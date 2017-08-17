//
//  State.swift
//  Cooldown
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import Foundation
import UserNotifications

// TODO: Uncomment when going back to Swift 4 Codable
//struct Cooldown: Codable {
struct Cooldown {
    var created: Date
    var remaining: TimeInterval
}

extension Cooldown {
    
    var target: Date { return created.addingTimeInterval(remaining) }
    
    // TODO: Remove when going back to Swift 4 Codable
    var jsonData: Data {
        let json: [String: Any] = ["created": created.timeIntervalSinceReferenceDate, "remaining": remaining]
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    // TODO: Remove when going back to Swift 4 Codable
    init(json: [String: Any]) {
        let createdInterval = json["created"] as! TimeInterval
        let created = Date(timeIntervalSinceReferenceDate: createdInterval)
        let remaining = json["remaining"] as! TimeInterval
        self.init(created: created, remaining: remaining)
    }
    
    static func +(left: Cooldown, right: Cooldown) -> Cooldown {
        let delta = right.created.timeIntervalSince(left.created)
        let remaining = max(left.remaining - delta, 0) + right.remaining
        return Cooldown(created: right.created, remaining: remaining)
    }
    
    static func +=(left: inout Cooldown, right: Cooldown) {
        left = left + right
    }
    
}


class State {
    
    static let shared = State()
    
    #if DEBUG
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown.dev")!
    #else
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown")!
    #endif
    
    var message: [String: Any] {
        return ["cooldown": cooldown.jsonData, "cooldownInterval": cooldownInterval]
    }
    
    var cooldown: Cooldown {
        get {
            guard let data = storage.data(forKey: "cooldown") else {
                return Cooldown(created: Date(), remaining: 0)
            }
            
            // TODO: Switch back when going back to Swift 4 Codable
            //                _cooldown = try? JSONDecoder().decode(Cooldown.self, from: data)
            guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
                return Cooldown(created: Date(), remaining: 0)
            }
            
            return Cooldown(json: json)
        }
        set {
            // TODO: Switch back when going back to Swift 4 Codable
            let data = newValue.jsonData //try? JSONEncoder().encode(newValue)
            storage.set(data, forKey: "cooldown")
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .brief
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.maximumUnitCount = 2
            
            let content = UNMutableNotificationContent()
            content.title = "Cooldown complete"
            content.body = "Time elapsed: \(formatter.string(from: newValue.remaining) ?? "???")"
            content.sound = UNNotificationSound.default()
            
            let components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: newValue.target)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let request = UNNotificationRequest(identifier: "cooldown-complete", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error { print(error) }
            }
        }
    }
    
    var cooldownInterval: TimeInterval {
        get {
            return storage.object(forKey: "cooldownInterval") as? TimeInterval ?? 60 * 60
        }
        set {
            storage.set(newValue, forKey: "cooldownInterval")
        }
    }
    
}
