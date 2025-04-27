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
  
  private let store = ManagedSettingsStore()
  private var applicationTokens: Set<Token<Application>> = []
  
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
  
  func startAppShield() {
    let whitelistMode = UserDefaults.standard.string(forKey: "whitelistMode")
    if whitelistMode == "strict" {
      updateWhitelist([])
    }
    if whitelistMode == "whitelist" {
      updateWhitelist(applicationTokens)
    }
    if whitelistMode == "loose" {
      stopAppShield()
    }
  }
  
  func updateApplicationTokens(_ tokens: Set<Token<Application>>) {
    applicationTokens = tokens
  }
}
