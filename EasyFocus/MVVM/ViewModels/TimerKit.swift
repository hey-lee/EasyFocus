//
//  TimerKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

protocol TimerKitProtocol {
  /// The duration of each session in minutes.
  var minutes: Int { get set }
  /// The total number of sessions to complete.
  var sessionsCount: Int { get set }
  /// Duration of short breaks between sessions in minutes.
  var shortBreak: Int { get set }
  /// Duration of long breaks after multiple sessions in minutes.
  var longBreak: Int { get set }
  /// Flag indicating if short breaks should start automatically.
  var autoStartShortBreaks: Bool { get set }
  /// Flag indicating if sessions should start automatically after breaks.
  var autoStartShortSessions: Bool { get set }
  /// The number of completed sessions.
  var completedSessions: Int { get }
  /// Total accumulated seconds across all sessions.
  var completedSeconds: Int { get }
  /// Total accumulated seconds in paused state across all pauses
  var completedSecondsPaused: Int { get }
  /// The timer object responsible for counting.
  var timer: Timer? { get set }
  /// Current timer mode (e.g., session, break).
  var mode: TimerKit.Mode { get set }
  /// Current timer state (e.g., running, paused).
  var state: TimerKit.State { get set }
  /// Type of current break (short/long).
  var breakType: TimerKit.BreakType { get set }
  /// Timestamp when the timer was started.
  var startedAt: Date { get set }
  /// Seconds elapsed since timer start.
  var secondsSinceStart: Int { get set }
  /// Seconds accumulated while timer was paused in sessions.
  var secondsOnPaused: Int { get set }
  /// Progress percentage of current session/break.
  var percent: Double { get set }
  /// Index of current session in the sequence.
  var sessionIndex: Int { get set }
  /// Session duration converted to seconds for calculations.
  var minutesInSeconds: Int { get set }
  /// Indicates if timer is counting forward (vs backward).
  var isForwardMode: Bool { get }
  /// Indicates if timer is currently active.
  var isActive: Bool { get }
  /// Formatted time components for display purposes.
  var display: (minutes: String, seconds: String) { get }
  /// Total duration of current session/break in seconds.
  var duration: Int { get }
  
  /// Begins timer countdown.
  func start()
  /// Pauses active timer.
  func pause()
  /// Resumes paused timer.
  func resume()
  /// Advances to next session/break in sequence.
  func nextSession()
  /// Stops and resets timer.
  func stop()
  /// Initializes timer object.
  func createTimer()
  /// Handles timer tick events.
  func tick()
  /// Handles completion of timer cycle.
  func onTimerCompletion()
  /// Converts seconds to formatted time string.
  func format(_ seconds: Int) -> String // mm:ss
  /// Calculates progress percentage for specified session.
  func getSessionProgress(_ index: Int) -> CGFloat
}

extension TimerKit {
  enum State: String, CustomStringConvertible {
    case idle, running, paused
    var description: String { rawValue }
  }
  
  enum BreakType: String, CustomStringConvertible {
    case short, long
    var description: String { rawValue }
  }
  
  enum Mode: String, CustomStringConvertible {
    case work, rest
    var description: String { rawValue }
  }
}

@Observable
final class TimerKit {
  static let shared = TimerKit()
  
  // impl TimerKit
}
