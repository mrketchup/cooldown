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
    public enum Mode: Codable {
        case accumulate, reset
    }
    
    public var title: String?
    public var mode: Mode = .accumulate
    public var interval: TimeInterval = 3600
    
    public private(set) var target: Date = .distantPast
    public private(set) var bumpCount = 0
    
    public var remaining: TimeInterval {
        max(target.timeIntervalSinceNow, 0)
    }
    
    public mutating func bump(multipliedBy multiplier: Double = 1) {
        bumpCount += 1
        
        let interval = interval * multiplier
        switch mode {
        case .accumulate:
            let startDate = max(target, Date())
            target = startDate.addingTimeInterval(interval)
        case .reset:
            target = Date(timeIntervalSinceNow: interval)
        }
    }
    
    public mutating func resetBumpCount() {
        bumpCount = 0
    }
}

public protocol StateObserver: AnyObject {
    func stateUpdated(_ state: State)
    func cooldownUpdated(_ cooldown: Cooldown)
}

public extension StateObserver {
    func stateUpdated(_ state: State) {}
    func cooldownUpdated(_ cooldown: Cooldown) {}
}

public final class State {
    
    private struct WeakObserver {
        weak var ref: StateObserver?
    }
    
    #if DEBUG
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown.dev")!
    #else
    private let storage = UserDefaults(suiteName: "group.mattjones.cooldown")!
    #endif
    
    private var observers: [WeakObserver] = []
    
    public var appContext: [String: Any] {
        return [
            "cooldown": try! JSONEncoder().encode(cooldown) // swiftlint:disable:this force_try
        ]
    }
    
    public var cooldown: Cooldown {
        get {
            guard let data = storage.data(forKey: "cooldown"),
                let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data)
                else {
                    return Cooldown()
            }
            
            return cooldown
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            storage.set(data, forKey: "cooldown")
            notify { $0.cooldownUpdated(newValue) }
        }
    }
    
    public init() {}
    
    public func register(_ observer: StateObserver) {
        guard !observers.contains(where: { $0.ref === observer }) else { return }
        observers.append(WeakObserver(ref: observer))
        observer.cooldownUpdated(cooldown)
        observer.stateUpdated(self)
    }
    
    public func unregister(_ observer: StateObserver) {
        observers.removeAll { $0.ref === observer }
    }
    
    private func notify(_ notifyChange: @escaping (StateObserver) -> Void) {
        observers.removeAll { $0.ref == nil }
        observers
            .compactMap { $0.ref }
            .forEach { notifyChange($0); $0.stateUpdated(self) }
    }
}
