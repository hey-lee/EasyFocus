//
//  NotificationService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import Foundation
import UserNotifications

enum NotificationType {
  case timerDone(seconds: Int)
  case restReminder
}

protocol NotificationServiceDelegate: AnyObject {
  func notificationDidTrigger(for type: NotificationType)
}

final class NotificationService: NSObject {
  weak var delegate: NotificationServiceDelegate?
  
  init(_ identifiers: Set<String> = []) {
    super.init()
    configureCategories(identifiers: identifiers)
    UNUserNotificationCenter.current().delegate = self
  }
}

// MARK - Permission
extension NotificationService {
  func requestAuthorization() async -> Bool {
    let result = try? await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound])
    return result ?? false
  }
  
  private func configureCategories(identifiers: Set<String>) {
    let categories = identifiers.map { id in
      UNNotificationCategory(
        identifier: id,
        actions: [],
        intentIdentifiers: [],
        options: .customDismissAction
      )
    }
    UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
  }
}

// MARK - Schedule Notification
extension NotificationService {
  func schedule(_ type: NotificationType) {
    let content = UNMutableNotificationContent()
    let trigger: UNNotificationTrigger
    
    switch type {
    case .timerDone(let seconds):
      content.title = "Timer Done!"
      content.body = "Your focus session is completed"
      trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
    case .restReminder:
      content.title = "Rest Time"
      content.body = "Take a short break"
      trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60, repeats: false)
    }
    
    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
  }
  
  func cancelAll() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
}

// MARK - handle callback
extension NotificationService: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
    delegate?.notificationDidTrigger(for: parseType(from: notification))
  }
  
  private func parseType(from notification: UNNotification) -> NotificationType {
    return .timerDone(seconds: 0)
  }
}
