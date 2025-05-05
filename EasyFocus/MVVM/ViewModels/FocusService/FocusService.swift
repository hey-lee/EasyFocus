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
  
  var state: StateMachine.State { sm.state }
  var mode: StateMachine.Mode { sm.mode }
  var settings: FocusSettings = FocusSettings.shared
  
  private var duration: Int {
    switch mode {
    case .work: return timer.mode == .forward ? Int.max : settings.minutes * ONE_MINUTE_IN_SECONDS
    case .rest: return (breakType == .short ? settings.shortBreak : settings.longBreak) * ONE_MINUTE_IN_SECONDS
    }
  }

  public var breakType: FocusService.BreakType {
    (completedSessionsCount % 4 == 0) ? .long : .short
  }
  public var display: (minutes: String, seconds: String) {
    let parts = format(timer.remainingSeconds).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
    
  }
  public var progress: Double = 0
  public var completedSessionsCount: Int = 0
  
  init() {
    timer.duration = duration
    timer.delegate = self
    notification.delegate = self
    sm.onStateChanged = onStateChange
    AppLifeCycleService.shared.addListener(self)
  }
}

// MARK - Core Controls
extension FocusService {
  func start() {
    timer.duration = duration
    _ = sm.emit(.start(mode))
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
}

// MARK - State Machine
extension FocusService {
  private func onStateChange(_ oldState: StateMachine.State, _ newState: StateMachine.State) {
    print("state changed from \(oldState) to \(newState)")
    
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
    _ = sm.emit(.finish)

    switch mode {
    case .work:
      onWorkTimerComplete()
    case .rest:
      onBreakTimerComplete()
    }
  }
  
  func onWorkTimerComplete() {
    if settings.autoStartShortBreaks {
      _ = sm.emit(.start(.rest))
    }
  }
  
  func onBreakTimerComplete() {
    completedSessionsCount += 1
    print("completedSessionsCount", completedSessionsCount)
    if completedSessionsCount >= settings.sessionsCount, state != .idle {
      _ = sm.emit(.finish)
    } else {
      if settings.autoStartSessions {
        _ = sm.emit(.start(.work))
      }
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

// MARK - Notification
extension FocusService: NotificationServiceDelegate {
  func didReceive(_ response: UNNotificationResponse) {
    print("didReceive", notification)
  }
}

extension FocusService: AppLifeCycleServiceDelegate {
  func didEnterBackground() {
    if case .running = state {
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
