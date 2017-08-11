//
//  SettingsViewController.swift
//  Cooldown
//
//  Created by Matt Jones on 8/9/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit

class Settings {
    
    static let shared = Settings()
    
    var _cooldownInterval: TimeInterval?
    var cooldownInterval: TimeInterval {
        get {
            if _cooldownInterval == nil {
                _cooldownInterval = UserDefaults.standard.object(forKey: "cooldownInterval") as? TimeInterval
            }
            
            return _cooldownInterval ?? 60 * 60
        }
        set {
            _cooldownInterval = newValue
            UserDefaults.standard.set(_cooldownInterval, forKey: "cooldownInterval")
        }
    }
    
}

class SettingsViewController: UIViewController {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var cooldownDatePicker: UIDatePicker!
    var settings: Settings = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Uncomment when ready for iOS 11
//        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOpacity = 0.15
//        shadowView.layer.shadowRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            // Workaround for a UIDatePicker bug not firing the first value change event
            self.cooldownDatePicker.countDownDuration = self.settings.cooldownInterval
        }
    }
    
    @IBAction func cooldownDatePickerValueChanged(_ sender: UIDatePicker) {
        settings.cooldownInterval = TimeInterval(sender.countDownDuration)
    }

    @IBAction func dismiss() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
