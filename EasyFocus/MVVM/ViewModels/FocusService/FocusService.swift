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
    timer.display
  }
  public var progress: Double = 0
  public var sessionIndex: Int = 0
  
  init() {
    timer.minutes = settings.minutes
    timer.duration = duration
    timer.delegate = self
    notify.delegate = self
    backgroundTaskService.delegate = self
    stateMachine.onStateChanged = onStateChange
  }
}

extension FocusService: TimerServiceDelegate {
  func onTick(elapsedSeconds: Int) {
    onElapsedUpdated(elapsedSeconds)
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
    sessionIndex += 1
    if sessionIndex >= settings.sessionsCount {
      _ = stateMachine.send(.finish)
    } else {
      mode = .rest
      _ = stateMachine.send(.start(.rest))
    }
  }
  
  func onBreakComplete() {}
  
  func onElapsedUpdated(_ elapsedSeconds: Int) {
    print(timer.duration, timer.remainingSeconds)
    if timer.mode == .countdown {
      progress = Double(elapsedSeconds) / Double(duration)
    }
  }
}

// MARK - StateMachine
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

// MARK - Core Controls
extension FocusService {
  @MainActor
  func start(_ mode: Mode) {
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
