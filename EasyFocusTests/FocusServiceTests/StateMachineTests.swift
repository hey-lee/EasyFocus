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
  
  func testStartFromIdle() {
    let exp = expectation(description: "emit .start to change state from .idle to .running(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .idle)
      XCTAssertEqual(new, .running(.work))
      exp.fulfill()
    }
    
    let result = machine.emit(.start(.work))
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testPauseFromRunning() {
    _ = machine.emit(.start(.work))
    
    let exp = expectation(description: "emit .pause to change state from .running(.work) to .paused(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(.work))
      XCTAssertEqual(new, .paused(.work))
      exp.fulfill()
    }
    
    let result = machine.emit(.pause)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testResumeFromPaused() {
    _ = machine.emit(.start(.work))
    _ = machine.emit(.pause)
    
    let exp = expectation(description: "emit .resume to change state from .paused(.work) to .running(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .paused(.work))
      XCTAssertEqual(new, .running(.work))
      exp.fulfill()
    }
    
    let result = machine.emit(.resume)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testFinishFromRunning() {
    _ = machine.emit(.start(.work))
    
    let exp = expectation(description: "emit .finish to change state from .running(.work) to .idle")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(.work))
      XCTAssertEqual(new, .idle)
      exp.fulfill()
    }
    
    let result = machine.emit(.finish)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testStopFromRunning() {
    _ = machine.emit(.start(.work))
    
    let exp = expectation(description: "emit .stop to change state from .running(.work) to .idle")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(.work))
      XCTAssertEqual(new, .idle)
      exp.fulfill()
    }
    
    let result = machine.emit(.stop)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  func testBackgroundFromRunning() {
    _ = machine.emit(.start(.work))
    
    let exp = expectation(description: "emit .background to change state from .running(.work) to .paused(.work)")
    machine.onStateChanged = { old, new in
      XCTAssertEqual(old, .running(.work))
      XCTAssertEqual(new, .paused(.work))
      exp.fulfill()
    }
    
    let result = machine.emit(.background)
    waitForExpectations(timeout: 0.1)
    XCTAssertTrue(result)
  }
  
  // MARK - 无效转换测试
  
  func testInvalidEventsInIdle() {
    let events: [StateEvent] = [
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
    _ = machine.emit(.start(.work))
    
    var callbackCalled = false
    machine.onStateChanged = { _, _ in callbackCalled = true }
    
    let result = machine.emit(.start(.work))
    XCTAssertFalse(result)
    XCTAssertFalse(callbackCalled)
    
  }
  
  func testConsecutiveStartFromIdle() {
    var callbackCount = 0
    machine.onStateChanged = { old, new in
      callbackCount += 1
      XCTAssertEqual(old, .idle)
      XCTAssertEqual(new, .running(.work))
    }
    
    let firstResult = machine.emit(.start(.work))
    XCTAssertTrue(firstResult)
    XCTAssertEqual(machine.state, .running(.work))
    XCTAssertEqual(callbackCount, 1)

    machine.onStateChanged = { _, _ in
      XCTFail("should not trigger onStateChanged")
    }
    
    let secondResult = machine.emit(.start(.work))
    XCTAssertFalse(secondResult)
    XCTAssertEqual(machine.state, .running(.work))
  }
  
  func testConsecutiveStartFromRunning() {
    _ = machine.emit(.start(.work))
    
    var callbackCount = 0
    machine.onStateChanged = { _, _ in
      callbackCount += 1
    }
    
    [1...3].forEach { _ in
      let result = machine.emit(.start(.work))
      XCTAssertFalse(result)
    }
    
    XCTAssertEqual(callbackCount, 0)
    XCTAssertEqual(machine.state, .running(.work))
  }
  
  func testDoubleStart() {
      let machine = StateMachine()
      XCTAssertTrue(machine.emit(.start(.work))) // success in first time
      XCTAssertFalse(machine.emit(.start(.work))) // fial in second time
  }
}
