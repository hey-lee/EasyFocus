//
//  TimerService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

protocol TimerServiceDelegate: AnyObject {
  func onTick(elapsedSeconds: Int)
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
  struct Configuration {
    let minutes: Int
    let duration: Int
  }
  
  public var minutes: Int = 0
  public var duration: Int = 0
  public var remainingSeconds: Int = 0
  public var display: (minutes: String, seconds: String) {
    let parts = format(remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  
  // MARK - Internal properties
  private var timer: Timer?
  private var startedAt: Date?
  private var elapsedBeforePause: Int = 0
  private var backgroundEnterTime: Date?
  
  // MARK - External properties
  var mode: Mode {
    minutes == 0 ? .forward : .countdown
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
    elapsedBeforePause = computeElapsed()
    startedAt = nil
  }
  
  public func resume() {
    startedAt = .now
    fireTimer()
  }
  
  public func stop(type: TimerCompletionType = .stop) {
    timer?.invalidate()
    startedAt = nil
    elapsedBeforePause = 0
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
    let elapsed = computeElapsed()
    
    remainingSeconds = max(duration - elapsed, 0)
    
    if mode == .countdown, elapsed >= duration {
      stop(type: .finish)
    } else {
      delegate?.onTick(elapsedSeconds: elapsed)
    }
  }
  
  func computeElapsed() -> Int {
    guard let startedAt else { return elapsedBeforePause }
    return Int(Date().timeIntervalSince(startedAt)) + elapsedBeforePause
  }
}

extension TimerService {
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
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
    elapsedBeforePause += backgroundTime
    self.backgroundEnterTime = nil
    
    if startedAt != nil {
      startedAt = .now
      fireTimer()
    }
  }
}
