//
//  FocusKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import BackgroundTasks

@Observable
class FocusKit {
  enum State: String, CustomStringConvertible {
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
  
  // AppStorage Properties
  var minutes: Int {
    set { UserDefaults.standard.set(newValue, forKey: "minutes") }
    get {
      if UserDefaults.standard.object(forKey: "minutes") == nil {
        return 1
      }
      return UserDefaults.standard.integer(forKey: "minutes")
    }
  }
  var sessionsCount: Int {
    set { UserDefaults.standard.set(newValue, forKey: "sessionsCount") }
    get {
      if UserDefaults.standard.object(forKey: "sessionsCount") == nil {
        return 4
      }
      return UserDefaults.standard.integer(forKey: "sessionsCount")
    }
  }
  var sessionIndex: Int {
    set { UserDefaults.standard.set(newValue, forKey: "sessionIndex") }
    get {
      if UserDefaults.standard.object(forKey: "sessionIndex") == nil {
        return 0
      }
      return UserDefaults.standard.integer(forKey: "sessionIndex")
    }
  }
  var restShort: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restShort") }
    get {
      if UserDefaults.standard.object(forKey: "restShort") == nil {
        return 5
      }
      return UserDefaults.standard.integer(forKey: "restShort")
    }
  }
  var restLong: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restLong") }
    get {
      if UserDefaults.standard.object(forKey: "restLong") == nil {
        return 20
      }
      return UserDefaults.standard.integer(forKey: "restLong")
    }
  }
  
  // Timer State
  var timer: Timer?
  var backgroundTask: BGTask?
  var lastBackgroundDate: Date?
  
  // Observable Properties
  var mode: Mode = .work
  var state: State = .idle
  var restType: RestType = .short
  var startedAt = Date.now
  var secondsSinceStart = 0
  var percent: Double = 0
  var secondsOnPaused = 0
  
  let minuteInSeconds = 60
  
  // Computed Properties
  var secondsLeft: Int { duration - secondsSinceStart }
  var isActive: Bool { state == .running || state == .paused }
  var display: (minutes: String, seconds: String) {
    let parts = format(secondsLeft).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  
  private var duration: Int {
    switch mode {
    case .work: minutes * minuteInSeconds
    case .rest: (restType == .short ? restShort : restLong) * minuteInSeconds
    }
  }
  
  // Lifecycle
  init() {
    setupBackgroundProcessing()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
  }
  
  // Timer Control
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
  
  func stop() {
    timer?.invalidate()
    state = .idle
    secondsSinceStart = 0
    percent = 0
    secondsOnPaused = 0
    backgroundTask?.setTaskCompleted(success: true)
  }
  
  // Background Handling
  private func setupBackgroundProcessing() {
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
  
  @objc private func handleBackground() {
    guard state == .running else { return }
    lastBackgroundDate = .now
    timer?.invalidate()
    scheduleNotification()
  }
  
  @objc private func handleForeground() {
    guard state == .running, let lastDate = lastBackgroundDate else { return }
    let backgroundTime = Int(Date.now.timeIntervalSince(lastDate))
    secondsSinceStart += backgroundTime
    lastBackgroundDate = nil
    createTimer()
  }
  func scheduleNotification() {
    guard state == .running else { return }
    NotificationKit.addNotification(TimeInterval(secondsLeft), "Timer Done!", "Your focus session is completed")
  }
  
  private func tick() {
    guard state == .running else { return }
    secondsSinceStart = Int(Date.now.timeIntervalSince(startedAt)) + secondsOnPaused
    percent = Double(secondsSinceStart) / Double(duration)
    
    guard secondsLeft > 0 else {
      handleTimerCompletion()
      return
    }
  }
  
  private func handleTimerCompletion() {
    if mode == .work {
      sessionIndex = (sessionIndex == sessionsCount) ? 0 : sessionIndex + 1
    }
    mode = mode == .work ? .rest : .work
    stop()
  }
  
  func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
}
