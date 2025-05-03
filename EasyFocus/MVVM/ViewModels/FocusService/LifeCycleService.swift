//
//  LifeCycleService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import SwiftUI
protocol LifeCycleServiceListener: AnyObject {
  func didEnterBackground()
  func willEnterForeground()
}

protocol LifeCycleServiceDelegate {
  func addListener(_ listener: LifeCycleServiceListener)
  func removeListener(_ listener: LifeCycleServiceListener)
}


final class LifeCycleService: LifeCycleServiceDelegate {
  static let shared = LifeCycleService()
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
      ($0 as? LifeCycleServiceListener)?.didEnterBackground()
    }
  }
  
  @objc private func willEnterForeground() {
    listeners.allObjects.forEach {
      ($0 as? LifeCycleServiceListener)?.willEnterForeground()
    }
  }
  
  func addListener(_ listener: LifeCycleServiceListener) {
    listeners.add(listener)
  }
  
  func removeListener(_ listener: LifeCycleServiceListener) {
    listeners.remove(listener)
  }
}
