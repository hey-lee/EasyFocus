//
//  Sessions.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/7.
//

import SwiftUI

extension FocusService.Sessions {
  enum BreakType: String, CustomStringConvertible {
    case short, long
    var description: String { rawValue }
  }
}

extension FocusService {
  @Observable
  final class Sessions {
    static let shared = Sessions()
    
    var progress: Double = 0
    var breakType: BreakType {
      isComplete ? .long : .short
    }
    var isComplete: Bool {
      completedCount == totalCount
    }
    var totalCount: Int {
      Settings.shared.sessionsCount
    }
    var completedCount: Int = 0
    var totalSeconds: Int {
      Settings.shared.minutes * FocusService.shared.ONE_MINUTE_IN_SECONDS
    }
    var completedSeconds: Int {
      completedCount * totalSeconds
    }
    
    func finish() {
      completedCount = max(min(completedCount + 1, totalCount), 0)
    }
    
    func restore() {
      completedCount = 0
    }
    
    func getPendingCount(by mode: StateMachine.Mode) -> Int {
      totalCount - completedCount - (mode == .work ? 1 : 0)
    }
    
    func getSessionProgress(_ index: Int, _ mode: StateMachine.Mode) -> CGFloat {
      completedCount > index ? 1 : ((completedCount == index) && mode == .work ? progress : 0)
    }
  }

}
