//
//  FocusKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import BackgroundTasks

extension FocusKit {
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
  
  enum Stage: String, CustomStringConvertible {
    case beforeStart, start, beforePause, pause, beforeResume, resume, beforeStop, stop, beforeNextSession, nextSession, completion
    var description: String { rawValue }
  }
  
  struct Stats {
    var secondsLeft: Int
    var sessionIndex: Int
    var completedSecondsCount: Int
  }
  
  struct OnChangeState {
    var state: FocusKit.State
    var stage: Stage
    var stats: Stats
  }
}

@Observable
class FocusKit {
  static let shared = FocusKit()
  
  private var onStateChange: (FocusKit.State, FocusKit.Stage, FocusKit.Stats) -> ()
  
  public var focus: Focus?
  public var minutes: Int {
    set { UserDefaults.standard.set(newValue, forKey: "minutes") }
    get { UserDefaults.standard.object(forKey: "minutes") as? Int ?? 20 }
  }
  public var sessionsCount: Int {
    set { UserDefaults.standard.set(newValue, forKey: "sessionsCount") }
    get { UserDefaults.standard.object(forKey: "sessionsCount") as? Int ?? 4 }
  }
  public var restShort: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restShort") }
    get { UserDefaults.standard.object(forKey: "restShort") as? Int ?? 5 }
  }
  public var restLong: Int {
    set { UserDefaults.standard.set(newValue, forKey: "restLong") }
    get { UserDefaults.standard.object(forKey: "restLong") as? Int ?? 15 }
  }
  public var autoStartSessions: Bool {
    set { UserDefaults.standard.set(newValue, forKey: "autoStartSessions") }
    get { UserDefaults.standard.bool(forKey: "autoStartSessions") }
  }
  public var autoStartShortBreaks: Bool {
    set { UserDefaults.standard.set(newValue, forKey: "autoStartShortBreaks") }
    get { UserDefaults.standard.bool(forKey: "autoStartShortBreaks") }
  }
  
  public var completedSessionsCount: Int {
    let completedSessions = sessionIndex
    let currentSession = (mode == .work && percent >= 0.8) ? 1 : 0
    
    return max(0, completedSessions + currentSession)
  }
  
  public var completedSecondsCount: Int {
    let completedSessionsSeconds = max(0, sessionIndex) * minutes * ONE_MINUTE_IN_SECONDS
    let currentSessionSeconds = mode == .work ? min(secondsSinceStart, minutes * ONE_MINUTE_IN_SECONDS) : 0
    return completedSessionsSeconds + currentSessionSeconds
  }
  
  public var totalSeconds: Int {
    sessionsCount * minutes * ONE_MINUTE_IN_SECONDS
  }
  
  private var shouldAutoStart: Bool {
    mode == .work ? autoStartSessions : autoStartShortBreaks
  }
  
  // Timer State
  private var timer: Timer?
  private var backgroundTask: BGTask?
  private var lastBackgroundDate: Date?
  
  // Observable Properties
  public var mode: Mode = .work
  public var state: FocusKit.State = .idle
  private var restType: RestType { (sessionIndex % 4 == 0) ? .long : .short }
  private var startedAt = Date.now
  private var secondsSinceStart = 0
  public var percent: Double = 0
  private var secondsOnPaused = 0
  public var sessionIndex = 0
  
  private let ONE_MINUTE_IN_SECONDS: Int = 60

  // Computed Properties
  public var isForwardMode: Bool { mode == .work && minutes == 0 }
  private var secondsLeft: Int {
    isForwardMode ? secondsSinceStart : (duration - secondsSinceStart)
  }
  public var isActive: Bool { state == .running || state == .paused }
  public var display: (minutes: String, seconds: String) {
    let parts = format(secondsLeft).components(separatedBy: ":")
    return (minutes: parts[0], seconds: parts[1])
  }
  
  private var duration: Int {
    switch mode {
    case .work: isForwardMode ? Int.max : minutes * ONE_MINUTE_IN_SECONDS
    case .rest: (restType == .short ? restShort : restLong) * ONE_MINUTE_IN_SECONDS
    }
  }
  
  init(_ onStateChange: @escaping (FocusKit.State, FocusKit.Stage, FocusKit.Stats) -> () = { _, _, _ in }) {
    self.onStateChange = onStateChange
  }
}

// MARK - focus storage
extension FocusKit {
  public func createFocusModel() {
    self.focus = Focus(
      minutes: minutes,
      sessionsCount: sessionsCount,
      restShort: restShort,
      restLong: restLong,
      label: TagsKit.shared.modelLabel,
    )
  }
  
  public func updateFocusModel() {
    if let focus {
      focus.endedAt = Date()
      focus.completedSecondsCount = completedSecondsCount
      focus.completedSessionsCount = completedSessionsCount
    }
  }
}

// MARK - focus controls
extension FocusKit {
  private func createTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      self?.tick()
    }
  }
  
  public func start() {
    updateStage(.beforeStart)
    
    guard state != .running else { return }
    state = .running
    startedAt = .now
    createTimer()
    scheduleBackgroundTask()
    
    updateStage(.start)
  }
  
  public func pause() {
    updateStage(.beforePause)
    
    guard state == .running else { return }
    state = .paused
    secondsOnPaused = secondsSinceStart
    timer?.invalidate()
    
    updateStage(.pause)
  }
  
  public func resume() {
    updateStage(.beforeResume)
    
    guard state == .paused else { return }
    state = .running
    startedAt = .now
    createTimer()
    scheduleBackgroundTask()
    
    updateStage(.resume)
  }
  
  private func nextSession() {
    updateStage(.beforeNextSession)
    
    timer?.invalidate()
    state = .idle
    percent = 0
    secondsSinceStart = 0
    secondsOnPaused = 0
    backgroundTask?.setTaskCompleted(success: true)
    
    updateStage(.nextSession)
  }
  
  public func stop() {
    updateStage(.beforeStop)
    
    nextSession()
    mode = .work
    sessionIndex = 0
    focus = nil
    
    updateStage(.stop)
  }
  
  public func onStateChange(_ onStateChange: @escaping (FocusKit.State, FocusKit.Stage, FocusKit.Stats) -> () = { _, _, _ in }) {
    self.onStateChange = onStateChange
  }
  
  private func updateStage(_ stage: Stage) {
    onStateChange(state, stage, .init(
      secondsLeft: secondsLeft,
      sessionIndex: sessionIndex,
      completedSecondsCount: completedSecondsCount)
    )
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
    updateStage(.completion)
    switch mode {
    case .work:
      handleWorkCompletion()
    case .rest:
      handleRestCompletion()
    }
  }
  
  private func handleWorkCompletion() {
    sessionIndex += 1
    
    if sessionIndex > sessionsCount {
      // Save state before stopping
      stop()
      return
    }
    
    nextSession()
    mode = .rest
    
    if autoStartShortBreaks {
      start()
    }
  }
  
  private func handleRestCompletion() {
    if sessionIndex >= sessionsCount {
      stop()
    } else {
      nextSession()
      mode = .work
      if autoStartSessions {
        start()
      }
    }
  }
  
  public func getSessionProgress(_ index: Int) -> CGFloat {
    sessionIndex > index ? 1 : ((sessionIndex == index) && mode == .work ? percent : 0)
  }
  
  public func format(_ seconds: Int) -> String {
    guard seconds > 0 else { return "00:00" }
    return String(format: "%02d:%02d", seconds / 60, seconds % 60)
  }
}


// MARK - notifications
extension FocusKit {
  private func scheduleNotification() {
    guard state == .running else { return }
    NotificationKit.addNotification(TimeInterval(max(0, minutes * ONE_MINUTE_IN_SECONDS - completedSecondsCount)), "Timer Done!", "Your focus session is completed")
  }
}

// MARK - background task
extension FocusKit {
  public func initNotification() {
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
    guard state == .running else { return }
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
    scheduleNotification()
    scheduleBackgroundTask()
    lastBackgroundDate = .now
    timer?.invalidate()
  }
  
  @objc private func willEnterForeground() {
    guard state == .running, let lastDate = lastBackgroundDate else { return }
    let backgroundTime = Int(Date.now.timeIntervalSince(lastDate))
    
    if backgroundTime >= secondsLeft {
      // Timer would have completed - handle completion
      secondsSinceStart = duration
      handleTimerCompletion()
    } else {
      // Timer still running - adjust time
      secondsSinceStart += backgroundTime
      createTimer()
    }
    
    lastBackgroundDate = nil
  }
}
