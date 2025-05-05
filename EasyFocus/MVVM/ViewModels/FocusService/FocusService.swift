//
//  FocusService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

extension FocusService {
  enum BreakType: String, CustomStringConvertible {
    case short, long
    var description: String { rawValue }
  }
}

fileprivate let ONE_MINUTE_IN_SECONDS: Int = 6

@Observable
final class FocusService {
  static let shared = FocusService()
  
  public var timer: TimerService = .init()
  
  var sm: StateMachine = .init()
  var notification: NotificationService = .init()
  var settings: FocusSettings = FocusSettings.shared
  
  public var duration: Int {
    switch sm.mode {
    case .work: timer.mode == .forward ? Int.max : settings.minutes * ONE_MINUTE_IN_SECONDS
    case .rest: (breakType == .short ? settings.shortBreakMinutes : settings.longBreakMinutes) * ONE_MINUTE_IN_SECONDS
    }
  }
  var isSessionsCompleted: Bool {
    completedSessionsCount % settings.sessionsCount == 0
  }
  // TOFIXED
  public var breakType: FocusService.BreakType {
    isSessionsCompleted ? .long : .short
  }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  public var totalRemainingSeconds: Int {
    if sm.mode == .work {
      let pendingSessions = settings.sessionsCount - completedSessionsCount - 1
      let pendingSeconds = pendingSessions * (settings.minutes + settings.shortBreakMinutes) * ONE_MINUTE_IN_SECONDS
      return pendingSeconds + timer.remainingSeconds
    } else {
      guard breakType == .short else { return 0 }
      let pendingSessions = settings.sessionsCount - completedSessionsCount
      let pendingWorkSeconds = pendingSessions * settings.minutes
      let pendingBreakSeconds = (pendingSessions - 1) * settings.shortBreakMinutes
      let pendingSeconds = (pendingWorkSeconds + pendingBreakSeconds) * ONE_MINUTE_IN_SECONDS
      return pendingSeconds + timer.remainingSeconds
    }
  }
  public var progress: Double = 0
  public var completedSessionsCount: Int = 0
  
  init() {
    timer.delegate = self
    notification.delegate = self
    sm.onStateChanged = onStateChange
    AppLifeCycleService.shared.addListener(self)
  }
}

// MARK - Core Controls
extension FocusService {
  func start() {
    _ = sm.emit(.start(sm.mode))
  }
  
  func pause() {
    _ = sm.emit(.pause)
  }
  
  func resume() {
    _ = sm.emit(.resume)
  }
  
  func stop() {
    _ = sm.emit(.stop)
  }
  
  func restoreSession() {
    completedSessionsCount = 0
  }
}

// MARK - State Machine
extension FocusService {
  private func onStateChange(_ oldState: StateMachine.State, _ newState: StateMachine.State) {
    print("state changed from \(oldState) to \(newState)")
    
    switch (oldState, newState) {
    case (.idle, .running):
      timer.duration = duration
      timer.start()
    case (.running, .paused):
      timer.pause()
    case (.paused, .running):
      timer.resume()
    case (_, .idle):
      timer.stop()
      timer.duration = duration
    default: break
    }
  }
}

// MARK - Timer Service Delegate
extension FocusService: TimerServiceDelegate {
  func onTick(_ secondsSinceStart: Int) {
    print(timer.remainingSeconds)
    if timer.mode == .countdown {
      progress = Double(secondsSinceStart) / Double(duration)
    }
  }
  
  func onTimerComplete(type: TimerCompletionType) {
    switch sm.mode {
    case .work:
      onWorkTimerComplete()
    case .rest:
      onBreakTimerComplete()
    }
  }
  
  func onWorkTimerComplete() {
    _ = sm.emit(.finish)
    
    completedSessionsCount = min(completedSessionsCount + 1, settings.sessionsCount)
    
    if isSessionsCompleted {
      restoreSession()
    } else {
      print("onWorkTimerComplete", breakType)
      if settings.autoStartShortBreaks {
        _ = sm.emit(.start(.rest))
      }
    }
  }
  
  func onBreakTimerComplete() {
    _ = sm.emit(.finish)
    
    if settings.autoStartSessions {
      _ = sm.emit(.start(.work))
    }
//    if isSessionsCompleted {
//      restoreSession()
//    } else {
//      if settings.autoStartSessions {
//        _ = sm.emit(.start(.work))
//      }
//    }
  }
}

// MARK - Helpers
extension FocusService {
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
}

// MARK - Notification
extension FocusService: NotificationServiceDelegate {
  func didReceive(_ response: UNNotificationResponse) {
    print("didReceive", notification)
  }
}

extension FocusService: AppLifeCycleServiceDelegate {
  func didEnterBackground() {
    if case .running = sm.state {
      notification.schedule(
        .init(
          title: "Timer is done!",
          body: "Your focus session is completed",
          timeInterval: timer.remainingSeconds
        )
      )
    }
    _ = sm.emit(.background)
  }
  
  func willEnterForeground() {
    _ = sm.emit(.foreground)
    notification.clearAll()
  }
}
