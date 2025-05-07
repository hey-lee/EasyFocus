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
    
    public var progress: Double = 0
    public var breakType: BreakType {
      isComplete ? .long : .short
    }
    public var isComplete: Bool {
      completedCount == totalCount
    }
    public var totalCount: Int {
      Settings.shared.sessionsCount
    }
    public var completedCount: Int = 0
    
    public func finish() {
      completedCount = min(completedCount + 1, totalCount)
    }
    
    public func restore() {
      completedCount = 0
    }
    
    public func getPendingCount(by mode: StateMachine.Mode) -> Int {
      totalCount - completedCount - (mode == .work ? 1 : 0)
    }
    
    public func getSessionProgress(_ index: Int, _ mode: StateMachine.Mode) -> CGFloat {
      completedCount > index ? 1 : ((completedCount == index) && mode == .work ? progress : 0)
    }
  }

}
