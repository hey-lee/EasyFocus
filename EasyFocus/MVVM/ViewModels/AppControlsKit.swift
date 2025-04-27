//
//  AppControlsKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/27.
//

import SwiftUI
import FamilyControls
import ManagedSettings

@Observable
final class AppControlsKit {
  static let shared = AppControlsKit()
  
  let store = ManagedSettingsStore()
  var observer: Task<Void, Never>?
  var selectedApps = [ApplicationToken]()
  var selection = [FamilyActivitySelection]()
  
  init() {
    if let data = UserDefaults.standard.data(forKey: "whitelist"),
       let apps = try? JSONDecoder().decode([ApplicationToken].self, from: data) {
      selectedApps = apps
    }
  }
  
  func requestAuthorization(_ completion: @escaping (Bool) -> Void = { _ in }) {
    Task {
      do {
        print("requestAuthorization")
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        print("Screen Time authorization succeeded")
        completion(true)
      } catch {
        print("Screen Time authorization failed:", error.localizedDescription)
        completion(false)
      }
    }
  }
  
}

extension AppControlsKit {
  func updateWhitelist(_ tokens: Set<Token<Application>>) {
    store.clearAllSettings()
    store.shield.applicationCategories = .all(except: tokens)
  }
  
  func stopAppShield() {
    store.clearAllSettings()
  }
}
