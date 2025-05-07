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


@Observable
final class FocusService {
  static let shared = FocusService()
  
  var focusModel: Focus?
  let ONE_MINUTE_IN_SECONDS: Int = 6
  private var _onStageChange: (StateMachine.Stage) -> () = { _ in }
  
  public var duration: Int {
    switch mode {
    case .work: timer.mode == .forward ? Int.max : settings.minutes * ONE_MINUTE_IN_SECONDS
    case .rest: (sessions.breakType == .short ? settings.shortBreakMinutes : settings.longBreakMinutes) * ONE_MINUTE_IN_SECONDS
    }
  }
  public var completedSecondsCount: Int {
    let currentSessionSeconds = mode == .work ? min(timer.secondsSinceStart, sessions.totalSeconds) : 0
    print("completedSecondsCount", sessions.completedSeconds, currentSessionSeconds)
    return sessions.completedSeconds + currentSessionSeconds
  }
  public var mode: StateMachine.Mode { sm.mode }
  public var state: StateMachine.State { sm.state }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  public var progress: Double { sessions.progress }
  
  public var totalRemainingSeconds: Int {
    computeTotalRemainingSeconds()
  }
  var totalSeconds: Int {
    if !settings.autoStartShortBreaks {
      seconds.work
    } else {
      if settings.autoStartSessions {
        seconds.total
      } else {
        seconds.cycle
      }
    }
  }
  var scheduleSeconds: Int {
    if !settings.autoStartShortBreaks {
      timer.remainingSeconds
    } else {
      if settings.autoStartSessions {
        totalRemainingSeconds
      } else {
        // calc first cycle elapsed seconds
        mode == .work ? timer.remainingSeconds + seconds.break : timer.remainingSeconds
      }
    }
  }
  
  private var backgroundSnapShot: SnapShot?
  
  private var notification: NotificationService = .init()
  
  private(set) var sm: StateMachine = .init()
  private(set) var timer: TimerService = .init()
  private(set) var seconds: Seconds = .init()
  private(set) var sessions: Sessions = .shared
  private(set) var settings: Settings = .shared
  
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
    _onStageChange(.willTransition(from: oldState, to: newState))
    
    switch (oldState, newState) {
    case (.idle, .running):
      timer.duration = duration
      timer.start()
    case (.running, .paused):
      timer.pause()
    case (.paused, .running):
      if case .foreground = event {
        timer.sink(seconds.currentCycleRemaining)
      } else {
        timer.resume()
      }
    case (_, .idle):
      timer.stop()
      timer.duration = duration
    default: break
    }
    
    _onStageChange(.didTransition(to: newState))
  }
  public func onStageChange(_ onStageChange: @escaping (StateMachine.Stage) -> () = { _ in }) {
    self._onStageChange = onStageChange
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
    switch mode {
    case .work:
      onWorkTimerComplete()
    case .rest:
      onBreakTimerComplete()
    }
  }
  
  func onWorkTimerComplete() {
    
    sessions.finish()
    
    if sessions.isComplete {
      sessions.restore()
      _ = sm.emit(.stop)
    } else {
      _ = sm.emit(.finish)
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

// MARK - Focus storage
extension FocusService {
  public func createFocusModel() {
    self.focusModel = Focus(
      minutes: settings.minutes,
      sessionsCount: sessions.completedCount,
      restShort: settings.shortBreakMinutes,
      restLong: settings.longBreakMinutes,
      label: TagsKit.shared.modelLabel,
    )
  }
  
  public func updateFocusModel() {
    if let focusModel {
      focusModel.endedAt = Date()
      focusModel.completedSecondsCount = completedSecondsCount
      focusModel.completedSessionsCount = sessions.completedCount
    }
  }

}

// MARK - Helpers
extension FocusService {
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
  
  public func updateDuration() {
    timer.duration = duration
  }
  
  public func getSessionProgress(_ index: Int) -> CGFloat {
    sessions.getSessionProgress(index, mode)
  }
  
  public func getMode(by secs: Int) -> StateMachine.Mode {
    let currentCycleSeconds = secs % seconds.cycle
    return currentCycleSeconds < seconds.work ? .work : .rest
  }
  
  private func computeTotalRemainingSeconds() -> Int {
    let pendingSessions = sessions.getPendingCount(by: mode)
    if mode == .work {
      let pendingSeconds = pendingSessions * seconds.cycle
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
        secondsOnEnter: totalSeconds - scheduleSeconds
      )
    }
    
    if sm.emit(.background) {
      print("notification.schedule", scheduleSeconds)
      notification.schedule(
        .init(
          title: "Timer is done!",
          body: "Your focus session is completed",
          seconds: scheduleSeconds
        )
      )
    }
  }
  
  func willEnterForeground() {
    notification.clearAll()
    
    guard let snapshop = backgroundSnapShot else { return }
    
    seconds.background = Int(Date().timeIntervalSince(snapshop.enterTime))
    let totalElapsedSeconds = snapshop.secondsOnEnter + seconds.background
    let mode = getMode(by: totalElapsedSeconds)
    
    sessions.completedCount = min(seconds.getSessionsCount(by: totalElapsedSeconds), sessions.totalCount)
    
    if sessions.isComplete {
      stop()
    } else {
      let currentCycleSeconds = seconds.getCurrentCycleSeconds(by: mode)
      let currentCycleElapsedSeconds = totalElapsedSeconds % (mode == .work ? seconds.cycle : seconds.work)
      
      seconds.currentCycleRemaining = currentCycleSeconds - currentCycleElapsedSeconds
    }
    
    _ = sm.emit(.foreground(mode))
    
    backgroundSnapShot = nil
  }
}
