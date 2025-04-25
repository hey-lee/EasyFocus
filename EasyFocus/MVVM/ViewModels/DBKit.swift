//
//  DBKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI
import CloudKit
import SwiftData
import CoreData

@Observable
final class DBKit {
  static let shared = DBKit()
  
  var iCloudStatus: String = "unknown"
  var iCloudAuthorized: Bool = false
  var syncStatus: String = "未同步"
  var lastSyncTime: Date?
  
  init() {
    checkiCloudStatus()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func checkiCloudStatus() {
    CKContainer.default().accountStatus { status, error in
      self.iCloudAuthorized = status == .available
      DispatchQueue.main.async {
        switch status {
        case .available: // The iCloud account credentials are available for this application
          self.iCloudStatus = "available"
          print("The iCloud account credentials are available for this application")
        case .noAccount: // No iCloud account is logged in on this device
          self.iCloudStatus = "noAccount"
          print("No iCloud account is logged in")
        case .restricted: // Parental Controls / Device Management has denied access to iCloud account
          self.iCloudStatus = "restricted"
          print("iCloud denied")
        case .couldNotDetermine: // An error occurred when getting the account status, consult the corresponding NSError.
          self.iCloudStatus = "couldNotDetermine"
          print("getting the account status error")
        case .temporarilyUnavailable: // An iCloud account is logged in but not ready. The user can be asked to verify their
          self.iCloudStatus = "temporarilyUnavailable"
          print("iCloud account is logged in but not ready")
        @unknown default:
          self.iCloudStatus = "unknown"
          print("unknown error")
        }
      }
    }
  }
  
  func setupNotifications() {
    NotificationCenter.default.addObserver(
      forName: .CKAccountChanged,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.checkiCloudStatus()
    }
    NotificationCenter.default.addObserver(
      forName: NSPersistentCloudKitContainer.eventChangedNotification,
      object: nil,
      queue: .main
    ) { [weak self] notification in
      guard let userInfo = notification.userInfo,
            let cloudEvent = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
        return
      }
      
      switch cloudEvent.type {
      case .setup:
        self?.syncStatus = "正在设置"
      case .import:
        self?.syncStatus = "正在导入数据"
      case .export:
        self?.syncStatus = "正在导出数据"
      @unknown default:
        self?.syncStatus = "未知状态"
      }
      
      if cloudEvent.endDate != nil {
        self?.lastSyncTime = Date()
        
        if let error = cloudEvent.error {
          self?.syncStatus = "同步错误: \(error.localizedDescription)"
        } else {
          self?.syncStatus = "同步完成"
        }
      }
    }
  }
  
//  func triggerManualSync() {
//    guard let container = modelContext.container as? NSPersistentCloudKitContainer else {
//      syncError = NSError(domain: "SyncError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "无效的容器类型"])
//      return
//    }
//    
//    isSyncing = true
//    syncError = nil
//    
//    Task {
//      do {
//        try await performCloudKitSync(container: container)
//        DispatchQueue.main.async {
//          self.lastSyncTime = Date()
//          self.isSyncing = false
//        }
//      } catch {
//        DispatchQueue.main.async {
//          self.syncError = error
//          self.isSyncing = false
//        }
//      }
//    }
//  }
//  
//  func performCloudKitSync(container: NSPersistentCloudKitContainer) async throws {
//    return try await withCheckedThrowingContinuation { continuation in
//      container.syncPersistentStores { _, result in
//        switch result {
//        case .success:
//          continuation.resume()
//        case .failure(let error):
//          continuation.resume(throwing: error)
//        }
//      }
//    }
//  }
}
