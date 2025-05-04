//
//  FocusService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

extension FocusService {
  enum Mode: String, CustomStringConvertible {
    case work, rest
    var description: String { rawValue }
  }
  
  enum State: Equatable {
    case idle
    case running(_ mode: Mode)
    case paused(_ mode: Mode)
  }
  
  enum BreakType: String, CustomStringConvertible {
    case short, long
    var description: String { rawValue }
  }
}

fileprivate let ONE_MINUTE_IN_SECONDS: Int = 60

@Observable
final class FocusService {
  static let shared = FocusService()
  
  public var timer: TimerService = .init()
  
  var stateMachine: StateMachine = .init()
  var notify: NotificationService = .init(["timer.done", "reminder.rest"])
  var backgroundTaskService: BackgroundTaskService = BackgroundTaskService.shared
  
  public var state: FocusService.State = .idle
  
  var settings: SettingsService = SettingsService.shared
  
  private var duration: Int {
    switch mode {
    case .work: timer.mode == .forward ? Int.max : settings.minutes * ONE_MINUTE_IN_SECONDS
    case .rest: (breakType == .short ? settings.shortBreak : settings.longBreak) * ONE_MINUTE_IN_SECONDS
    }
  }
  
  private var lastBackgroundDate: Date?
  
  public var mode: FocusService.Mode = .rest
  public var breakType: FocusService.BreakType {
    (sessionIndex % 4 == 0) ? .long : .short
  }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
    
  }
  public var progress: Double = 0
  public var sessionIndex: Int = 0
  
  init() {
    timer.duration = duration
    timer.delegate = self
    notify.delegate = self
    backgroundTaskService.delegate = self
    stateMachine.onStateChanged = onStateChange
  }
}

// MARK - Core Controls
extension FocusService {
  func start(_ mode: Mode) {
    timer.duration = duration
    _ = stateMachine.send(.start(mode))
  }
  
  func pause() {
    _ = stateMachine.send(.pause)
  }
  
  func resume() {
    _ = stateMachine.send(.resume)
  }
  
  func stop() {
    _ = stateMachine.send(.stop)
  }
}

// MARK - State Machine
extension FocusService {
  private func onStateChange(_ oldState: FocusService.State, _ newState: FocusService.State) {
    updateStage(.willTransition(from: oldState, to: newState))
    
    switch (oldState, newState) {
    case (.idle, .running):
      timer.start()
    case (.running, .paused):
      timer.pause()
    case (.paused, .running):
      timer.resume()
    case (_, .idle):
      timer.stop()
    default: break
    }
    updateStage(.didTransition(to: newState))
  }
  
  private func updateStage(_ stage: TransitionStage) {
    // print("stage", stage)
  }
}

// MARK - Timer Service Delegate
extension FocusService: TimerServiceDelegate {
  func onTick(_ secondsSinceStart: Int) {
    if timer.mode == .countdown {
      progress = Double(secondsSinceStart) / Double(duration)
    }
  }
  
  func onTimerComplete() {
    switch mode {
    case .work:
      onWorkComplete()
    case .rest:
      onBreakComplete()
    }
  }
  
  func onWorkComplete() {
    if settings.autoStartShortBreaks {
      _ = stateMachine.send(.start(.rest))
    }
  }
  
  func onBreakComplete() {
    sessionIndex += 1
    if sessionIndex >= settings.sessionsCount {
      _ = stateMachine.send(.finish)
    } else {
      _ = stateMachine.send(.start(.work))
    }
  }
}

// MARK - Helpers
extension FocusService {
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
}

// MARK - Background Task
extension FocusService: BackgroundTaskServiceDelegate {
  func onTaskExpiration() {
    _ = stateMachine.send(.pause)
  }
  
  func onTaskComplete() {}
  
  func scheduleBackgroundTask() {
    guard case .running = stateMachine.state else { return }
    backgroundTaskService.scheduleTask(seconds: timer.remainingSeconds)
  }
}

// MARK - Notification
extension FocusService: NotificationServiceDelegate {
  func notificationDidTrigger(for type: NotificationType) {
    switch type {
    case .timerDone:
      _ = stateMachine.send(.finish)
    case .restReminder:
      print()
    }
  }
  
  func scheduleNotification() {
    notify.schedule(.timerDone(seconds: 40))
  }
  
  private func cancelNotifications() {
    notify.cancelAll()
  }
}
