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
}
