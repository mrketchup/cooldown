//
//  State.swift
//  Cooldown
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import Foundation
import UserNotifications

public struct Cooldown: Codable {
    public var created: Date
    public var remaining: TimeInterval
    public init(created: Date, remaining: TimeInterval) {
        self.created = created
        self.remaining = remaining
    }
}

public extension Cooldown {
    
    public var target: Date { return created.addingTimeInterval(remaining) }
    
    public static func +(left: Cooldown, right: Cooldown) -> Cooldown {
        let delta = right.created.timeIntervalSince(left.created)
        let remaining = max(left.remaining - delta, 0) + right.remaining
        return Cooldown(created: right.created, remaining: remaining)
    }
    
    public static func +=(left: inout Cooldown, right: Cooldown) {
        left = left + right
    }
    
}


public class State {
    
    public static let shared = State()
    
    #if DEBUG
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown.dev")!
    #else
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown")!
    #endif
    
    public var appContext: [String: Any] {
        return ["cooldown": try! JSONEncoder().encode(cooldown), "cooldownInterval": cooldownInterval]
    }
    
    public var cooldown: Cooldown {
        get {
            guard let data = storage.data(forKey: "cooldown"),
                let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data)
                else
            {
                return Cooldown(created: Date(), remaining: 0)
            }
            
            return cooldown
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
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
    
    public var cooldownInterval: TimeInterval {
        get {
            return storage.object(forKey: "cooldownInterval") as? TimeInterval ?? 60 * 60
        }
        set {
            storage.set(newValue, forKey: "cooldownInterval")
        }
    }
    
}
