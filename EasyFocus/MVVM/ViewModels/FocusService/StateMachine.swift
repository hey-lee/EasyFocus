//
//  StateMachine.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/2.
//

import SwiftUI

extension StateMachine {
  enum Mode: String, CustomStringConvertible {
    case work, rest
    var description: String { rawValue }
  }
  
  enum State: Equatable {
    case idle
    case running(_ mode: Mode)
    case paused(_ mode: Mode)
  }
  
  enum Event {
    case start(_ mode: Mode)
    case pause
    case resume
    case finish
    case stop
    case background
    case foreground
  }
  
  enum Stage {
    case willTransition(from: State, to: State)
    case didTransition(to: State)
  }
}

@Observable
final class StateMachine {
  private(set) var state: State = .idle
  public var mode: Mode {
    switch state {
    case .idle:
      .work
    case .running(let mode), .paused(let mode):
      mode
    }
  }
  
  public var onStateChanged: ((State, State) -> Void)?
  
  func emit(_ event: Event) -> Bool {
    print("state machine emit \(event)")
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
      // count down finished
    case (.running, .finish):
      transition(to: .idle)
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
      print("invalid event \(event) on state \(state)")
      return false
    }
  }
  
  private func transition(to newState: State) {
    let oldState = state
    state = newState
    
    onStateChanged?(oldState, newState)
  }
}
