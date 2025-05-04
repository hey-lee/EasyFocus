//
//  TimerService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

protocol TimerServiceDelegate: AnyObject {
  func onTick(_ secondsSinceStart: Int)
  func onTimerComplete(type: TimerCompletionType)
}

enum TimerCompletionType {
  case finish, stop, background
}

@Observable
final class TimerService {
  enum Mode {
    case countdown, forward
  }
  
  // MARK - External properties
  public var duration: Int = 0
  public var mode: Mode = .countdown
  public var remainingSeconds: Int {
   mode == .forward ? secondsSinceStart : max(duration - secondsSinceStart, 0)
  }
  
  // MARK - Internal properties
  private var timer: Timer?
  private var startedAt: Date?
  private var secondsSinceStart: Int = 0
  private var secondsOnPaused: Int = 0
  private var backgroundEnterTime: Date?
  weak var delegate: TimerServiceDelegate?
  
  init() {
    AppLifeCycleService.shared.addListener(self)
  }
  
  deinit {
    timer?.invalidate()
    AppLifeCycleService.shared.removeListener(self)
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK - External Controls
extension TimerService {
  public func start() {
    timer?.invalidate()
    startedAt = .now
    fireTimer()
  }
  
  public func pause() {
    timer?.invalidate()
    secondsOnPaused = computeSecondsSinceStart()
    startedAt = nil
  }
  
  public func resume() {
    startedAt = .now
    fireTimer()
  }
  
  public func stop(type: TimerCompletionType = .stop) {
    timer?.invalidate()
    startedAt = nil
    secondsOnPaused = 0
    secondsSinceStart = 0
  }
}

// MARK - Timer
private extension TimerService {
  func fireTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.onTick()
    }
    timer?.fire()
  }
  
  func onTick() {
    secondsSinceStart = computeSecondsSinceStart()
    
    delegate?.onTick(secondsSinceStart)
    
    if mode == .countdown, secondsSinceStart >= duration {
      delegate?.onTimerComplete(type: .finish)
    }
  }
  
  func computeSecondsSinceStart() -> Int {
    guard let startedAt else { return secondsOnPaused }
    return Int(Date().timeIntervalSince(startedAt)) + secondsOnPaused
  }
}

// MARK - Background time compensation
extension TimerService: AppLifeCycleServiceDelegate {
  func didEnterBackground() {
    backgroundEnterTime = .now
    timer?.invalidate()
  }
  
  func willEnterForeground() {
    guard let backgroundEnterTime else { return }
    
    let backgroundTime = Int(Date().timeIntervalSince(backgroundEnterTime))
    secondsOnPaused += backgroundTime
    self.backgroundEnterTime = nil
    
    if startedAt != nil {
      startedAt = .now
      fireTimer()
    }
  }
}
