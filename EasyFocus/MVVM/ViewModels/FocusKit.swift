//
//  FocusKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import BackgroundTasks

extension FocusKit {
  enum FocusState: String, CustomStringConvertible {
    case idle, running, paused
    var description: String { rawValue }
  }
  
  enum RestType: String, CustomStringConvertible {
    case short, long
    var description: String { rawValue }
  }
  
  enum Mode: String, CustomStringConvertible {
    case work, rest
    var description: String { rawValue }
  }
}

@Observable
class FocusKit {
  static let shared = FocusKit()
  var focus: Focus?
  var minutes: Int {
    set { UserDefaults.standard.set(newValue, forKey: "minutes") }
    get { UserDefaults.standard.object(forKey: "minutes") as? Int ?? 20 }
  }
  var sessionsCount: Int {
    set { UserDefaults.standard.set(newValue, forKey: "sessionsCount") }
    get { UserDefaults.standard.object(forKey: "sessionsCount") as? Int ?? 4 }
  }
  var restShort: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restShort") }
    get { UserDefaults.standard.object(forKey: "restShort") as? Int ?? 5 }
  }
  var restLong: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restLong") }
    get { UserDefaults.standard.object(forKey: "restLong") as? Int ?? 15 }
  }
  var autoStartSessions: Bool {
    set { UserDefaults.standard.set(newValue, forKey: "autoStartSessions") }
    get { UserDefaults.standard.object(forKey: "autoStartSessions") as? Bool ?? false }
  }
  var autoStartShortBreaks: Bool {
    set { UserDefaults.standard.set(newValue, forKey: "autoStartShortBreaks") }
    get { UserDefaults.standard.object(forKey: "autoStartShortBreaks") as? Bool ?? false }
  }

  var completedSessionsCount: Int {
    let completedSessions = sessionIndex
    let currentSession = (mode == .work && percent >= 0.8) ? 1 : 0
    
    return max(0, completedSessions + currentSession)
  }

  var completedSecondsCount: Int {
    let completedSessionsSeconds = sessionIndex * minutes * minuteInSeconds
    let currentSessionSeconds = mode == .work ? secondsSinceStart : 0
    
    return completedSessionsSeconds + currentSessionSeconds
  }

  var completedMinutesCount: Int {
    let completedSessionsTime = sessionIndex * minutes
    let currentSessionTime = mode == .work ? Int(Double(minutes) * percent) : 0
    
    return completedSessionsTime + currentSessionTime
  }
  
  // Timer State
  var timer: Timer?
  var backgroundTask: BGTask?
  var lastBackgroundDate: Date?
  
  // Observable Properties
  var mode: Mode = .work
  var state: FocusState = .idle
  var restType: RestType = .short
  var startedAt = Date.now
  var secondsSinceStart = 0
  var percent: Double = 0
  var secondsOnPaused = 0
  var sessionIndex = 0
  
  let minuteInSeconds = 60
  
  // Computed Properties
  var isForwardMode: Bool { mode == .work && minutes == 0 }
  var secondsLeft: Int {
    isForwardMode ? secondsSinceStart : (duration - secondsSinceStart)
  }
  var isActive: Bool { state == .running || state == .paused }
  var display: (minutes: String, seconds: String) {
    let parts = format(secondsLeft).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  
  private var duration: Int {
    switch mode {
    case .work: isForwardMode ? Int.max : minutes * minuteInSeconds
    case .rest: (restType == .short ? restShort : restLong) * minuteInSeconds
    }
  }
  
  init() {}
}

// MARK - focus controls
extension FocusKit {
  func createFocusModel() {
    self.focus = Focus(
      minutes: minutes,
      sessionsCount: sessionsCount,
      restShort: restShort,
      restLong: restLong,
      label: TagsKit.shared.modelLabel,
    )
  }
  func updateFocusModel() {
    if let focus {
      focus.endedAt = Date()
      focus.completedSecondsCount = completedSecondsCount
      focus.completedMinutesCount = completedMinutesCount
      focus.completedSessionsCount = completedSessionsCount
    }
  }
  private func createTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
    }
  }
  func start() {
    guard state != .running else { return }
    state = .running
    startedAt = .now
    scheduleBackgroundTask()
    createTimer()
  }
  
  func pause() {
    guard state == .running else { return }
    state = .paused
    secondsOnPaused = secondsSinceStart
    timer?.invalidate()
  }
  
  func resume() {
    guard state == .paused else { return }
    state = .running
    startedAt = .now
    scheduleBackgroundTask()
    createTimer()
  }
  
  func nextSession() {
    timer?.invalidate()
    state = .idle
    percent = 0
    secondsSinceStart = 0
    secondsOnPaused = 0
    backgroundTask?.setTaskCompleted(success: true)
  }
  
  func stop() {
    nextSession()
    mode = .work
    sessionIndex = 0
    focus = nil
  }
  
  private func tick() {
    guard state == .running else { return }
    secondsSinceStart = Int(Date.now.timeIntervalSince(startedAt)) + secondsOnPaused
    
    if !isForwardMode {
      percent = Double(secondsSinceStart) / Double(duration)
      if secondsLeft <= 0 {
        handleTimerCompletion()
      }
    }
  }
  
  private func handleTimerCompletion() {
    if mode == .work {
      sessionIndex = (sessionIndex == sessionsCount) ? 0 : sessionIndex + 1
    }

    mode = mode == .work ? .rest : .work
    
    if sessionIndex == 0 {
      stop()
    } else {
      nextSession()
      let shouldAutoStart = mode == .work ? autoStartSessions : autoStartShortBreaks
      if shouldAutoStart {
        start()
      }
    }
  }
  
  func getSessionProgress(_ index: Int) -> CGFloat {
    sessionIndex > index ? 1 : ((sessionIndex == index) && mode == .work ? percent : 0)
  }
  
  func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
}


// MARK - notifications
extension FocusKit {
  func scheduleNotification() {
    guard state == .running else { return }
    NotificationKit.addNotification(TimeInterval(secondsLeft), "Timer Done!", "Your focus session is completed")
  }
}

// MARK - background task
extension FocusKit {
  func initNotification() {
    initTaskScheduler()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(didEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(willEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  private func initTaskScheduler() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: "co.banli.apps.easyfocus.timer",
      using: .main
    ) { [weak self] task in
      self?.handleBackgroundTask(task as! BGProcessingTask)
    }
  }
  
  private func scheduleBackgroundTask() {
    let request = BGProcessingTaskRequest(identifier: "co.banli.apps.easyfocus.timer")
    request.requiresNetworkConnectivity = false
    request.requiresExternalPower = false
    request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(secondsLeft))
    
    try? BGTaskScheduler.shared.submit(request)
  }
  
  private func handleBackgroundTask(_ task: BGProcessingTask) {
    backgroundTask = task
    task.expirationHandler = { [weak self] in
      self?.stop()
    }
    
    if state == .running {
      task.setTaskCompleted(success: true)
    }
  }
  
  @objc private func didEnterBackground() {
    guard state == .running else { return }
    lastBackgroundDate = .now
    timer?.invalidate()
    scheduleNotification()
  }
  
  @objc private func willEnterForeground() {
    guard state == .running, let lastDate = lastBackgroundDate else { return }
    let backgroundTime = Int(Date.now.timeIntervalSince(lastDate))
    secondsSinceStart += backgroundTime
    lastBackgroundDate = nil
    createTimer()
  }
}
