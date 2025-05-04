//
//  TimerService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

protocol TimerServiceDelegate: AnyObject {
  func onTick(_ secondsSinceStart: Int)
}

extension TimerServiceDelegate {
  func onTimerComplete(type: TimerCompletionType) {}
}

enum TimerCompletionType {
  case finish, stop, background
}

@Observable
final class TimerService {
  enum Mode {
    case countdown, forward
  }

  public var duration: Int = 0
  public var remainingSeconds: Int {
    mode == .forward ? secondsSinceStart : max(duration - secondsSinceStart, 0)
  }
  
  // MARK - Internal properties
  private var timer: Timer?
  private var startedAt: Date?
  private var secondsSinceStart: Int = 0
  private var secondsOnPaused: Int = 0
  private var backgroundEnterTime: Date?
  
  // MARK - External properties
  var mode: Mode {
    duration == 0 ? .forward : .countdown
  }
  weak var delegate: TimerServiceDelegate?
  
  private var lifeCycle: LifeCycleService = .init()
  
  init() {
    lifeCycle.addListener(self)
  }
  
  deinit {
    timer?.invalidate()
    lifeCycle.removeListener(self)
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK - External Controls
extension TimerService {
  public func start() {
    stop()
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
    delegate?.onTimerComplete(type: type)
  }
}

// MARK - Timer
private extension TimerService {
  func fireTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.onTick()
    }
    // fire immediately
    timer?.fire()
  }
  
  func onTick() {
    secondsSinceStart = computeSecondsSinceStart()
    
    if mode == .countdown, secondsSinceStart >= duration {
      stop(type: .finish)
    }

    delegate?.onTick(secondsSinceStart)
  }
  
  func computeSecondsSinceStart() -> Int {
    guard let startedAt else { return secondsOnPaused }
    return Int(Date().timeIntervalSince(startedAt)) + secondsOnPaused
  }
}

// MARK - Background time compensation
extension TimerService: LifeCycleServiceListener {
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
