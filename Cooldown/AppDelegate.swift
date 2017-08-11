//
//  AppDelegate.swift
//  Cooldown
//
//  Created by Matt Jones on 8/8/17.
//  Copyright © 2017 Matt Jones. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(red: 0.1, green: 0.8, blue: 0.1, alpha: 1)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if !granted, let error = error { print(error) }
        }
        
        return true
    }
    
}
