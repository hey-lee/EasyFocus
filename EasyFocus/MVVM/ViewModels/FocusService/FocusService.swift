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
  struct SnapShot {
    var enterTime: Date
    var secondsOnEnter: Int
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
  private var isSessionsCompleted: Bool {
    completedSessionsCount % settings.sessionsCount == 0
  }
  public var breakType: FocusService.BreakType {
    isSessionsCompleted ? .long : .short
  }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  public var progress: Double = 0
  public var completedSessionsCount: Int = 0
  public var remainingTotalSeconds: Int {
    computeTotalRemainingSeconds()
  }
  
  public var totalSeconds: Int {
    return cycleSeconds * settings.sessionsCount - breakSeconds
  }
  private var workSeconds: Int {
    settings.minutes * ONE_MINUTE_IN_SECONDS
  }
  private var breakSeconds: Int {
    settings.shortBreakMinutes * ONE_MINUTE_IN_SECONDS
  }
  private var cycleSeconds: Int {
    workSeconds + breakSeconds
  }
  private var currentCycleRemainingSeconds: Int = 0

  private var backgroundSnapShot: SnapShot?
  
  init() {
    timer.delegate = self
    notification.delegate = self
    sm.onStateChanged = onStateChange
    AppLifeCycleService.shared.addListener(self)
  }
}

// MARK - Core Controls
extension FocusService {
  func start(_ mode: StateMachine.Mode = .work) {
    _ = sm.emit(.start(mode))
  }
  
  func pause() {
    _ = sm.emit(.pause)
  }
  
  func resume() {
    _ = sm.emit(.resume)
  }
  
  func stop() {
    restoreSession()
    _ = sm.emit(.stop)
  }
  
  func restoreSession() {
    completedSessionsCount = 0
  }
}

// MARK - State Machine
extension FocusService {
  private func onStateChange(_ oldState: StateMachine.State, _ newState: StateMachine.State, _ event: StateMachine.Event) {
    print("state changed from \(oldState) to \(newState)")
    
    switch (oldState, newState) {
    case (.idle, .running):
      timer.duration = duration
      timer.start()
    case (.running, .paused):
      timer.pause()
    case (.paused, .running):
      if case .foreground = event {
        timer.sink(currentCycleRemainingSeconds)
      } else {
        timer.resume()
      }
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
  }
}

// MARK - Helpers
extension FocusService {
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
  
  public func getMode(by seconds: Int) -> StateMachine.Mode {
    let currentCycleSeconds = seconds % cycleSeconds
    return currentCycleSeconds < workSeconds ? .work : .rest
  }
  
  public func getSessionsCount(by seconds: Int) -> Int {
    let cycleCount = Int(floor(Double(seconds) / Double(cycleSeconds)))
    let remainingSessionsCount = Int(floor(Double(seconds % cycleSeconds) / Double(workSeconds)))
    
    return cycleCount + remainingSessionsCount
  }
  
  private func computeTotalRemainingSeconds() -> Int {
    if sm.mode == .work {
      let pendingSessions = settings.sessionsCount - completedSessionsCount - 1
      let pendingSeconds = pendingSessions * cycleSeconds
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
      backgroundSnapShot = SnapShot(
        enterTime: .now,
        secondsOnEnter: totalSeconds - remainingTotalSeconds
      )
      print("didEnterBackground", totalSeconds, remainingTotalSeconds)
    }

    if sm.emit(.background) {
      print("notification.schedule", remainingTotalSeconds)
      notification.schedule(
        .init(
          title: "Timer is done!",
          body: "Your focus session is completed",
          timeInterval: remainingTotalSeconds
        )
      )
    }
  }
  
  func willEnterForeground() {
    notification.clearAll()
    
    guard let snapshop = backgroundSnapShot else { return }
    
    let workSeconds = settings.minutes * ONE_MINUTE_IN_SECONDS
    let backgroundSeconds = Int(Date().timeIntervalSince(snapshop.enterTime))
    let totalElapsedSeconds = snapshop.secondsOnEnter + backgroundSeconds
    let mode = getMode(by: totalElapsedSeconds)

    completedSessionsCount = min(getSessionsCount(by: totalElapsedSeconds), settings.sessionsCount)
    
    if completedSessionsCount == settings.sessionsCount {
      stop()
    } else {
      let currentCycleSeconds = mode == .work ? workSeconds : breakSeconds
      let currentCycleElapsedSeconds = totalElapsedSeconds % (mode == .work ? cycleSeconds : workSeconds)
      let remainingTotalSeconds = totalSeconds - totalElapsedSeconds
      currentCycleRemainingSeconds = currentCycleSeconds - currentCycleElapsedSeconds
    }
    
    _ = sm.emit(.foreground(mode))
    
    backgroundSnapShot = nil
  }
}
