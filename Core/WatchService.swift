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

public final class WatchService: NSObject {
    
    private let state: State
    private var isProcessing = false
    
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
    
    init(state: State) {
        self.state = state
    }
    
    public func activate() {
        WCSession.default.delegate = self
        if WCSession.isSupported() && WCSession.default.activationState == .notActivated {
            WCSession.default.activate()
        }
    }
    
}

extension WatchService: WCSessionDelegate {
    
    #if !os(watchOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    public func sessionDidDeactivate(_ session: WCSession) {}
    #endif
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error { print(error) }
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        process(applicationContext)
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        process(message)
    }
    
    private func process(_ dictionary: [String: Any]) {
        guard let data = dictionary["cooldown"] as? Data,
            let cooldown = try? JSONDecoder().decode(Cooldown.self, from: data),
            let interval = dictionary["cooldownInterval"] as? TimeInterval
            else {
                return
        }
        
        DispatchQueue.main.sync {
            self.isProcessing = true
            state.cooldown = cooldown
            state.cooldownInterval = interval
            self.isProcessing = false
        }
    }
    
}

extension WatchService: StateObserver {
    
    public func stateUpdated(_ state: State) {
        guard !isProcessing else { return }
        
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
