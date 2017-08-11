//
//  ViewController.swift
//  Cooldown
//
//  Created by Matt Jones on 8/8/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit
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

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var cooldownLabel: UILabel!
    @IBOutlet var plusButton: UIButton!
    var displayLink: CADisplayLink?
    var settings: Settings = .shared
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    let formatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .abbreviated
        f.allowedUnits = [.hour, .minute, .second]
        f.maximumUnitCount = 2
        return f
    }()
    
    var _cooldown: Cooldown?
    var cooldown: Cooldown {
        get {
            if _cooldown == nil, let data = UserDefaults.standard.data(forKey: "cooldown") {
                // TODO: Switch back when going back to Swift 4 Codable
//                _cooldown = try? JSONDecoder().decode(Cooldown.self, from: data)
                if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                    _cooldown = Cooldown(json: json)
                }
            }
            
            return _cooldown ?? Cooldown(created: Date(), remaining: 0)
        }
        set {
            _cooldown = newValue
            // TODO: Switch back when going back to Swift 4 Codable
            let data = newValue.jsonData //try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: "cooldown")
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cooldownLabel.font = .monospacedDigitSystemFont(ofSize: 120, weight: UIFontWeightLight)
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
            let title2 = formatter.string(from: settings.cooldownInterval * 2)!
            sheet.addAction(UIAlertAction(title: "+\(title2)", style: .default, handler: handler(2)))
            let title15 = formatter.string(from: settings.cooldownInterval * 1.5)!
            sheet.addAction(UIAlertAction(title: "+\(title15)", style: .default, handler: handler(1.5)))
            let title1 = formatter.string(from: settings.cooldownInterval)!
            sheet.addAction(UIAlertAction(title: "+\(title1)", style: .default, handler: handler(1)))
            let title05 = formatter.string(from: settings.cooldownInterval * 0.5)!
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
        let interval = max(cooldown.target.timeIntervalSinceNow, 0)
        cooldownLabel.text = formatter.string(from: interval)
        
        let good = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
        let ok = UIColor(red: 1, green: 0.7, blue: 0, alpha: 1)
        let bad = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1)
        let percent = min(interval / settings.cooldownInterval / 3, 1)
        if percent <= 0.5 {
            view.backgroundColor = good.blended(with: ok, percent: CGFloat(percent * 2))
        } else {
            view.backgroundColor = ok.blended(with: bad, percent: CGFloat((percent - 0.5) * 2))
        }
    }
    
    func bumpCooldown(multiplier: Double = 1) {
        cooldown += Cooldown(created: Date(), remaining: settings.cooldownInterval * multiplier)
    }

}

extension UIColor {
    
    var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    func blended(with color: UIColor, percent: CGFloat) -> UIColor {
        let rgba1 = rgba
        let rgba2 = color.rgba
        let r = rgba1.r * (1 - percent) + rgba2.r * percent
        let g = rgba1.g * (1 - percent) + rgba2.g * percent
        let b = rgba1.b * (1 - percent) + rgba2.b * percent
        let a = rgba1.a * (1 - percent) + rgba2.a * percent
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
}
