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
  let workMode: FocusService.Mode = .work
  let restMode: FocusService.Mode = .rest
  
  override func setUp() {
    super.setUp()
    machine = StateMachine()
  }
  
  func testStartFromIdle() {
    let exp = expectation(description: "emit .start to change state from .idle to .running(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .idle)
      XCTAssertEqual(new, .running(self.workMode))
      exp.fulfill()
    }
    
    let result = machine.emit(.start(workMode))
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testPauseFromRunning() {
    _ = machine.emit(.start(workMode))
    
    let exp = expectation(description: "emit .pause to change state from .running(.work) to .paused(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(self.workMode))
      XCTAssertEqual(new, .paused(self.workMode))
      exp.fulfill()
    }
    
    let result = machine.emit(.pause)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testResumeFromPaused() {
    _ = machine.emit(.start(workMode))
    _ = machine.emit(.pause)
    
    let exp = expectation(description: "emit .resume to change state from .paused(.work) to .running(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .paused(self.workMode))
      XCTAssertEqual(new, .running(self.workMode))
      exp.fulfill()
    }
    
    let result = machine.emit(.resume)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testFinishFromRunning() {
    _ = machine.emit(.start(workMode))
    
    let exp = expectation(description: "emit .finish to change state from .running(.work) to .idle")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(self.workMode))
      XCTAssertEqual(new, .idle)
      exp.fulfill()
    }
    
    let result = machine.emit(.finish)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testStopFromRunning() {
    _ = machine.emit(.start(workMode))
    
    let exp = expectation(description: "emit .stop to change state from .running(.work) to .idle")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(self.workMode))
      XCTAssertEqual(new, .idle)
      exp.fulfill()
    }
    
    let result = machine.emit(.stop)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testBackgroundFromRunning() {
    _ = machine.emit(.start(workMode))
    
    let exp = expectation(description: "emit .background to change state from .running(.work) to .paused(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(self.workMode))
      XCTAssertEqual(new, .paused(self.workMode))
      exp.fulfill()
    }
    
    let result = machine.emit(.background)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  // MARK - 无效转换测试
  
  func testInvalidEventsInIdle() {
    let events: [FocusEvent] = [
      .pause,
      .resume,
      .finish,
      .stop,
      .background,
      .foreground
    ]
    
    for event in events {
      let result = machine.emit(event)
      XCTAssertFalse(result, "Event \(event) should be invalid")
      XCTAssertEqual(machine.state, .idle)
    }
  }
  
  func testInvalidStartFromRunning() {
    _ = machine.emit(.start(workMode))
    
    var callbackCalled = false
    machine.onStateChanged = { _, _ in callbackCalled = true }
    
    let result = machine.emit(.start(workMode))
    XCTAssertFalse(result)
    XCTAssertFalse(callbackCalled)
  }
}
