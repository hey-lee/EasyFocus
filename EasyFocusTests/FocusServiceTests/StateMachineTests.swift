//
//  StateMachineTests.swift
//  FocusServiceTests
//
//  Created by DBL on 2025/5/5.
//

import XCTest
@testable import EasyFocus

class FocusServiceTests: XCTestCase {
  var machine: StateMachine!
  
  override func setUp() {
    super.setUp()
    machine = StateMachine()
  }
}
