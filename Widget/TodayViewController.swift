//
//  TodayViewController.swift
//  Widget
//
//  Created by Matt Jones on 8/13/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet var cooldownLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    var displayLink: CADisplayLink?
    
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute, .second]
        f.maximumUnitCount = 2
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 80, weight: UIFontWeightLight)
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        bumpCooldown()
        updateUI()
    }
    
    @objc func updateUI() {
        let interval = max(State.shared.cooldown.target.timeIntervalSinceNow, 0)
        cooldownLabel.text = formatter.string(from: interval)
        
        let percent = min(interval / State.shared.cooldownInterval / 3, 1)
        if percent <= 0.5 {
            view.backgroundColor = UIColor.cooldownGreen.blended(with: .cooldownYellow, percent: CGFloat(percent * 2))
        } else {
            view.backgroundColor = UIColor.cooldownYellow.blended(with: .cooldownRed, percent: CGFloat((percent - 0.5) * 2))
        }
    }
    
    func bumpCooldown(multiplier: Double = 1) {
        State.shared.cooldown += Cooldown(created: Date(), remaining: State.shared.cooldownInterval * multiplier)
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        completionHandler(.newData)
    }
    
}
