//
//  Seconds.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/7.
//

import SwiftUI

extension FocusService {
  @Observable
  final class Seconds {
    var total: Int {
      cycle * Sessions.shared.totalCount - `break`
    }
    var background: Int = 0
    var work: Int {
      Settings.shared.minutes * FocusService.shared.ONE_MINUTE_IN_SECONDS
    }
    var `break`: Int {
      Settings.shared.shortBreakMinutes * FocusService.shared.ONE_MINUTE_IN_SECONDS
    }
    var cycle: Int {
      work + `break`
    }
    var currentCycleRemaining: Int = 0
    
    func getCurrentCycleSeconds(by mode: StateMachine.Mode) -> Int {
      mode == .work ? work : `break`
    }
    
    func getSessionsCount(by seconds: Int) -> Int {
      let cycleCount = Int(floor(Double(seconds) / Double(cycle)))
      let remainingSessionsCount = Int(floor(Double(seconds % cycle) / Double(work)))
      
      return cycleCount + remainingSessionsCount
    }
    
    func computeTotalRemaining() {}
  }
}
