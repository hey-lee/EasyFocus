//
//  LifeCycleService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import SwiftUI
protocol AppLifeCycleServiceDelegate: AnyObject {
  func didEnterBackground()
  func willEnterForeground()
}

final class AppLifeCycleService {
  static let shared = AppLifeCycleService()
  private var listeners = NSHashTable<AnyObject>.weakObjects()

  public func setupObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  @objc private func didEnterBackground() {
    listeners.allObjects.forEach {
      ($0 as? AppLifeCycleServiceDelegate)?.didEnterBackground()
    }
  }
  
  @objc private func willEnterForeground() {
    listeners.allObjects.forEach {
      ($0 as? AppLifeCycleServiceDelegate)?.willEnterForeground()
    }
  }
  
  func addListener(_ listener: AppLifeCycleServiceDelegate) {
    listeners.add(listener)
  }
  
  func removeListener(_ listener: AppLifeCycleServiceDelegate) {
    listeners.remove(listener)
  }
}
