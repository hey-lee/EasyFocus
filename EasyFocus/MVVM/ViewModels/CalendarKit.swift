//
//  CalendarKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/27.
//

import SwiftUI
import EventKit

@Observable
final class CalendarKit {
  static let shared = CalendarKit()
  private let eventStore = EKEventStore()
  
  func requestAccess() async throws -> Bool {
    if #available(iOS 17.0, *) {
      return try await withCheckedThrowingContinuation { continuation in
        eventStore.requestWriteOnlyAccessToEvents {
          granted, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(returning: granted)
          }
        }
      }
    } else {
      return try await withCheckedThrowingContinuation { continuation in
        eventStore.requestAccess(to: .event) {
          granted, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else {
            continuation.resume(returning: granted)
          }
        }
      }
    }
  }
  
  func addFocusToCalendar(_ focus: Focus) async throws -> String {
    let status = EKEventStore.authorizationStatus(for: .event)
    guard status == .fullAccess || status == .writeOnly else {
      return "We need permission to write to your calendar."
    }
    guard let calendar = eventStore.defaultCalendarForNewEvents else {
      return "Cannot retrieve the default calendar."
    }
    
    let event = EKEvent(eventStore: eventStore)
    if let label = focus.label {
      event.title = label.name
    }
    
    event.startDate = focus.startedAt
    event.endDate = focus.endedAt
    event.notes = focus.notes
    event.calendar = calendar
    
    try eventStore.save(event, span: .thisEvent)
    
    return event.eventIdentifier
  }
}
