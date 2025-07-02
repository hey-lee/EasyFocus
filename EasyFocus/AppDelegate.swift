//
//  AppDelegate.swift
//  Costrack
//
//  Created by DBL on 2024/9/19.
//

import SwiftUI
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
//    Purchases.logLevel = .verbose
//    Purchases.configure(withAPIKey: "appl_TAICzJUuIyCenilYTIjTSItDEQW")

    AppLifeCycleService.shared.setupObservers()
    BackgroundTaskService.shared.registerTask()
    
    UserDefaults.standard.register(defaults: [
      // app
      "enableSound": true,
      "enableHaptic": true,
      "whitelistMode": "loose",
      "enableAppWhitelist": false,
      // focus
      "minutes": 20,
      "sessionsCount": 4,
      "restShort": 5,
      "restLong": 15,
      "enableReminder": false,
      "enableiCloudSync": false,
      "enableCalendarSync": false,
      "autoStartSessions": false,
      "autoStartShortBreaks": false,
    ])
    
    
    return true
  }
  
}
