//
//  NotificationService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import Foundation
import UserNotifications

struct NotificationEntity {
  var title: String
  var subtitle: String?
  var body: String
  var symbol: String?
  var timeInterval: Int
  var repeats: Bool = false
}

protocol NotificationServiceDelegate: AnyObject {
  func didReceive(_ response: UNNotificationResponse)
}

final class NotificationService: NSObject {
  static let shared = NotificationService()
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
  func schedule(_ entity: NotificationEntity) {
    guard entity.timeInterval > 0 else {
      print("notification schedule failed: time interval must be greater than 0")
      return
    }
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(entity.timeInterval), repeats: entity.repeats)
    let content = UNMutableNotificationContent()
    
    content.title = entity.title
    content.body = entity.body
    if let subtitle = entity.subtitle {
      content.subtitle = subtitle
    }
    if let imageName = entity.symbol {
      content.launchImageName = imageName
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
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
    delegate?.didReceive(response)
  }
}
