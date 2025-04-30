//
//  StoreKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import Foundation

@Observable
final class StoreKit {
  static let shared = StoreKit()
  
  enum RangeType: String, CustomStringConvertible {
    case day, week, month, year
    var description: String { rawValue }
  }
  
  var rangeType: String = ""
  var focusEvents: [Focus] = []
  var totalSeconds: Int {
    focusEvents.reduce(0) { $0 + $1.completedSecondsCount }
  }
  var totalMinutes: Int {
    toMinutes(totalSeconds)
  }
  var eventsWeekMap: [String: [Focus]] {
    focusEvents
      .sorted { $0.createdAt < $1.createdAt }
      .reduce(into: [:]) { weekMap, event in
        let createdAt = event.createdAt.format("yyyy-MM-dd")
        weekMap[createdAt, default: []].append(event)
      }
  }
  var rangedEvents: [Focus] {
    focusEvents.filter {
      let calendar = Calendar.current
      let now = Date()
      let eventDate = $0.createdAt
      
      switch rangeType {
      case "day":
        return calendar.isDate(eventDate, inSameDayAs: now)
      case "week":
        let weekRange = calendar.dateInterval(of: .weekOfYear, for: now)!
        return weekRange.contains(eventDate)
      case "month":
        return calendar.isDate(eventDate, equalTo: now, toGranularity: .month)
      case "year":
        return calendar.isDate(eventDate, equalTo: now, toGranularity: .year)
      default:
        return false
      }
    }
  }
  var labelStats: [FocusLabel: [Focus]] {
    rangedEvents
      .filter { $0.label != nil }
      .reduce(into: [:]) { dict, focus in
        if let label = focus.label {
          dict[label, default: []].append(focus)
        }
      }
  }
  var labelEventsMap: [String: [Focus]] {
    Dictionary(grouping: focusEvents.filter { $0.label != nil }) { $0.label!.name }
  }
  var labelValueMap: [String: Int] {
    labelEventsMap.mapValues { events in
      events.reduce(0) { $0 + $1.completedSecondsCount }
    }
  }
  
  func percent(_ seconds: Int) -> Int {
    Int((Double(seconds) / Double(totalSeconds) * 100.0).rounded())
  }
  
  func toMinutes(_ seconds: Int) -> Int {
    Int(Double(seconds) / 60.0)
  }
}
