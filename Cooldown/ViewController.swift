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

import UIKit
import WatchConnectivity
import Core_iOS

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var cooldownLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    let formatter = DateComponentsFormatter.cooldownFormatter
    var displayLink: CADisplayLink?
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 120, weight: .light)
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink?.preferredFramesPerSecond = 4
        displayLink?.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        bumpCooldown()
        updateUI()
    }
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        bumpCooldown(multiplier: -1)
        updateUI()
    }
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if case .began = sender.state {
            let handler: (Double) -> (UIAlertAction) -> Void = { multiplier in
                return { _ in
                    self.bumpCooldown(multiplier: multiplier)
                }
            }
            
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let title2 = formatter.string(from: State.shared.cooldownInterval * 2)!
            sheet.addAction(UIAlertAction(title: "+\(title2)", style: .default, handler: handler(2)))
            
            let title15 = formatter.string(from: State.shared.cooldownInterval * 1.5)!
            sheet.addAction(UIAlertAction(title: "+\(title15)", style: .default, handler: handler(1.5)))
            
            let title1 = formatter.string(from: State.shared.cooldownInterval)!
            sheet.addAction(UIAlertAction(title: "+\(title1)", style: .default, handler: handler(1)))
            
            let title05 = formatter.string(from: State.shared.cooldownInterval * 0.5)!
            sheet.addAction(UIAlertAction(title: "+\(title05)", style: .default, handler: handler(0.5)))
            
            sheet.addAction(UIAlertAction(title: "Edit Cooldown Interval...", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "settings", sender: nil)
            }))
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            sheet.popoverPresentationController?.sourceView = plusButton
            sheet.popoverPresentationController?.sourceRect = plusButton.bounds.insetBy(dx: 0, dy: 20)
            present(sheet, animated: true, completion: nil)
        }
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
        do { try WCSession.default.updateApplicationContext(State.shared.appContext) }
        catch { print(error) }
    }

}
