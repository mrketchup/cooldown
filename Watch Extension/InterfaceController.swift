//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var interfaceGroup: WKInterfaceGroup!
    @IBOutlet var cooldownTimer: WKInterfaceTimer!
    weak var timer: Timer?
    
    override func willActivate() {
        super.willActivate()
        updateTimer()
        
        let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
        self.timer = timer
        self.timer?.fire()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        cooldownTimer.stop()
        timer?.invalidate()
    }
    
    @IBAction func swipeDown(_ sender: WKSwipeGestureRecognizer) {
        bumpCooldown(multiplier: -1)
        updateUI()
        updateTimer()
    }
    
    @IBAction func addButtonPressed(_ sender: WKInterfaceButton) {
        bumpCooldown()
        updateUI()
        updateTimer()
    }
    
    @objc func updateUI() {
        let interval = max(State.shared.cooldown.target.timeIntervalSinceNow, 0)
        let percent = min(interval / State.shared.cooldownInterval / 3, 1)
        let color: UIColor
        if percent <= 0.5 {
            color = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            color = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
        
        interfaceGroup.setBackgroundColor(color)
    }
    
    func updateTimer() {
        if State.shared.cooldown.target > Date() {
            cooldownTimer.setDate(State.shared.cooldown.target)
            cooldownTimer.start()
        } else {
            cooldownTimer.setDate(Date())
            cooldownTimer.stop()
        }
    }
    
    func bumpCooldown(multiplier: Double = 1) {
        State.shared.cooldown += Cooldown(created: Date(), remaining: State.shared.cooldownInterval * multiplier)
        do { try WCSession.default().updateApplicationContext(State.shared.appContext) }
        catch { print(error) }
    }

}
