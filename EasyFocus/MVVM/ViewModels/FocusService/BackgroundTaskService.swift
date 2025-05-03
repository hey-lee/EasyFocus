//
//  BackgroundTaskService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import BackgroundTasks

protocol BackgroundTaskServiceDelegate: AnyObject {
  func onTaskExpiration()
  func onTaskComplete()
}

@Observable
final class BackgroundTaskService {
  static let shared = BackgroundTaskService("co.banli.apps.easyfocus.timer")
  weak var delegate: BackgroundTaskServiceDelegate?
  
  private var backgroundTask: BGTask?
  private let identifier: String
  
  init(_ identifier: String) {
    self.identifier = identifier
  }
}

extension BackgroundTaskService {
  func scheduleTask(seconds: Int) {
    let request = BGProcessingTaskRequest(identifier: identifier)
    request.requiresNetworkConnectivity = false
    request.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(seconds))
    
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Failed to schedule BGTask: \(error)")
    }
  }
  
  func cancelTask() {
    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
  }
}

extension BackgroundTaskService {
  public func registerTask() {
    BGTaskScheduler.shared.register(
      forTaskWithIdentifier: identifier,
      using: nil
    ) { [weak self] task in
      self?.handleTask(task as! BGProcessingTask)
    }
  }
  
  private func handleTask(_ task: BGProcessingTask) {
    backgroundTask = task
    task.expirationHandler = { [weak self] in
      self?.delegate?.onTaskExpiration()
    }

    delegate?.onTaskComplete()
    task.setTaskCompleted(success: true)
  }
}
