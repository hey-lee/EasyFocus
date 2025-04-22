//
//  NotificationKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import Foundation
import UserNotifications

@Observable
final class NotificationKit {
  static func check(completion: @escaping (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized:
        completion(true)
      case .notDetermined:
        center.requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
          completion(allowed)
        }
      default:
        completion(false)
      }
    }
  }
  
  static func addNotification(_ seconds: TimeInterval, _ title: String, _ body: String) {
    let center = UNUserNotificationCenter.current()
    // clear all notifications
    center.removeAllDeliveredNotifications()
    center.removeAllPendingNotificationRequests()
    
    // set up content
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = UNNotificationSound.default
    
    // set trigger
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: trigger
    )

    center.add(request)
  }
}
