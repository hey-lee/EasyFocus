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
  
  
  public var duration: Int {
    switch sm.mode {
    case .work: timer.mode == .forward ? Int.max : settings.minutes * ONE_MINUTE_IN_SECONDS
    case .rest: (sessions.breakType == .short ? settings.shortBreakMinutes : settings.longBreakMinutes) * ONE_MINUTE_IN_SECONDS
    }
  }
  public var mode: StateMachine.Mode { sm.mode }
  public var state: StateMachine.State { sm.state }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  public var progress: Double { sessions.progress }

  public var remainingTotalSeconds: Int {
    computeTotalRemainingSeconds()
  }
  
  public var backgroundSeconds: Int = 0
  public var totalSeconds: Int {
    return cycleSeconds * sessions.totalCount - breakSeconds
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
  
  private var notification: NotificationService = .init()
  
  private(set) var sm: StateMachine = .init()
  private(set) var timer: TimerService = .init()
  private(set) var sessions: FocusSessions = .shared
  private(set) var settings: FocusSettings = .shared
  
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
    sessions.restore()
    _ = sm.emit(.stop)
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
      sessions.progress = max(min(Double(secondsSinceStart) / Double(duration), 1), 0)
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
    
    sessions.finish()
    
    if sessions.isComplete {
      sessions.restore()
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
  
  public func getSessionProgress(_ index: Int) -> CGFloat {
    sessions.getSessionProgress(index, sm.mode)
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
    let pendingSessions = sessions.getPendingCount(by: sm.mode)
    if sm.mode == .work {
      let pendingSeconds = pendingSessions * cycleSeconds
      return pendingSeconds + timer.remainingSeconds
    } else {
      guard sessions.breakType == .short else { return 0 }
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
    
    backgroundSeconds = Int(Date().timeIntervalSince(snapshop.enterTime))
    let totalElapsedSeconds = snapshop.secondsOnEnter + backgroundSeconds
    let mode = getMode(by: totalElapsedSeconds)

    sessions.completedCount = min(getSessionsCount(by: totalElapsedSeconds), sessions.totalCount)
    
    if sessions.isComplete {
      stop()
    } else {
      let currentCycleSeconds = mode == .work ? workSeconds : breakSeconds
      let currentCycleElapsedSeconds = totalElapsedSeconds % (mode == .work ? cycleSeconds : workSeconds)

      currentCycleRemainingSeconds = currentCycleSeconds - currentCycleElapsedSeconds
    }
    
    _ = sm.emit(.foreground(mode))

    backgroundSnapShot = nil
  }
}
