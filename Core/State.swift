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
    
    public static func + (left: Cooldown, right: Cooldown) -> Cooldown {
        return add(left: left, right: right)
    }
    
    public static func += (left: inout Cooldown, right: Cooldown) {
        left = add(left: left, right: right)
    }
    
    private static func add(left: Cooldown, right: Cooldown) -> Cooldown {
        let delta = right.created.timeIntervalSince(left.created)
        let remaining = max(left.remaining - delta, 0) + right.remaining
        return Cooldown(created: right.created, remaining: remaining)
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
        return [
            "cooldown": try! JSONEncoder().encode(cooldown), // swiftlint:disable:this force_try
            "cooldownInterval": cooldownInterval
        ]
    }
    
    public var cooldown: Cooldown {
        get {
            guard let data = storage.data(forKey: "cooldown"),
                let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data)
                else {
                    return Cooldown(created: Date(), remaining: 0)
            }
            
            return cooldown
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            storage.set(data, forKey: "cooldown")
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
