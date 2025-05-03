//
//  StateMachine.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

enum FocusEvent {
  case start(_ mode: FocusService.Mode)
  case pause
  case resume
  case finish
  case stop
  case background
  case foreground
}

enum TransitionStage {
  case willTransition(from: FocusService.State, to: FocusService.State)
  case didTransition(to: FocusService.State)
}

@Observable
final class StateMachine {
  private(set) var state: FocusService.State = .idle
  
  var shouldStop: Bool = false
  var onStateChanged: ((FocusService.State, FocusService.State) -> Void)?
  
  func send(_ event: FocusEvent) -> Bool {
    switch (state, event) {
    // start
    case (.idle, .start(let mode)):
      transition(to: .running(mode))
      return true
    // pause
    case (.running(let mode), .pause):
      transition(to: .paused(mode))
      return true
    // resume
    case (.paused(let mode), .resume):
      transition(to: .running(mode))
      return true
    // count down completed
    case (.running(let mode), .finish):
      onModeComplete(mode)
      return true
    // stop manually
    case (.running, .stop), (.paused, .stop):
      transition(to: .idle)
      return true
    // handle background & foreground events
    case (.running(let mode), .background):
      transition(to: .paused(mode))
      return true
    case (.paused(let mode), .foreground):
      transition(to: .running(mode))
      return true
    default:
      print("invalid action \(event) on state \(state)")
      return false
    }
  }
  
  private func transition(to newState: FocusService.State) {
    let oldState = state
    state = newState
    
    onStateChanged?(oldState, newState)
  }
  
  private func onModeComplete(_ mode: FocusService.Mode) {
    switch mode {
    case .work:
      // transition state from work to rest
      transition(to: .running(.rest))
    case .rest:
      // TODO - check if completed sessions
      if shouldStop {
        transition(to: .idle)
      } else {
        transition(to: .running(.work))
      }
    }
  }
}
