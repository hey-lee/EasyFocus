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
  
  var iCloudStatus: String {
    set {
      UserDefaults.standard.set(newValue, forKey: "iCloudStatus")
    }
    get {
      UserDefaults.standard.string(forKey: "iCloudStatus") ?? ""
    }
  }
  var iCloudAuthorized: Bool = false
  var iCloudSyncStatus: String {
    set {
      UserDefaults.standard.set(newValue, forKey: "iCloudSyncStatus")
    }
    get {
      UserDefaults.standard.string(forKey: "iCloudSyncStatus") ?? ""
    }
  }
  var lastSyncTime: Date?
  
  init() {
    checkiCloudStatus()
    setupNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
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
            let event = userInfo[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
        return
      }

      switch event.type {
      case .setup:
        self?.iCloudSyncStatus = "setup"
      case .import:
        self?.iCloudSyncStatus = "import"
      case .export:
        self?.iCloudSyncStatus = "export"
      @unknown default:
        self?.iCloudSyncStatus = "unknown"
      }
      
      if event.endDate != nil {
        self?.lastSyncTime = Date()
        
        if let error = event.error {
          self?.iCloudSyncStatus = "iCloud sync error: \(error.localizedDescription)"
        } else {
          self?.iCloudSyncStatus = "success"
        }
      }
    }
  }
}
