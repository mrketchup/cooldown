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
import WatchConnectivity

class WatchService: NSObject {
    
    static let shared = WatchService()
    
    var stateChanged: (() -> Void)?
    
    private var isConnected: Bool {
        #if os(watchOS)
        return true
        #else
        return WCSession.default.isPaired && WCSession.default.isWatchAppInstalled
        #endif
    }
    
    private var canUpdateContext: Bool {
        return WCSession.isSupported() && WCSession.default.activationState == .activated && isConnected
    }
    
    private var canSendMessage: Bool {
        return canUpdateContext && WCSession.default.isReachable
    }
    
    func activate() {
        if WCSession.isSupported() && WCSession.default.activationState == .notActivated {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func stateUpdated(_ state: State) {
        if canSendMessage {
            WCSession.default.sendMessage(state.appContext, replyHandler: nil)
        } else if canUpdateContext {
            do {
                try WCSession.default.updateApplicationContext(state.appContext)
            } catch {
                print(error)
            }
        }
    }
    
}

extension WatchService: WCSessionDelegate {
    
    #if !os(watchOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error { print(error) }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext["cooldown"] as? Data,
            let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data),
            let interval = applicationContext["cooldownInterval"] as? TimeInterval
            else {
                return
        }
        
        State.shared.cooldown = cooldown
        State.shared.cooldownInterval = interval
        DispatchQueue.main.async(execute: stateChanged ?? {})
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let data = message["cooldown"] as? Data,
            let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data),
            let interval = message["cooldownInterval"] as? TimeInterval
            else {
                return
        }
        
        State.shared.cooldown = cooldown
        State.shared.cooldownInterval = interval
        DispatchQueue.main.async(execute: stateChanged ?? {})
        
        #if !os(watchOS)
        NotificationService.shared.scheduleNotification(for: State.shared.cooldown)
        #endif
    }
    
}
