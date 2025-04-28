//
//  Date++.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/28.
//

import SwiftUI

extension Date {
  var isToday: Bool {
    Calendar.current.isDateInToday(self)
  }
  
  func isEqualTo(_ date: Date) -> Bool {
    Calendar.current.isDate(self, inSameDayAs: date)
  }
  
  func format(_ tpl: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = tpl
    
    return formatter.string(from: self)
  }
  
  struct WeekDay: Identifiable {
    var id: UUID = UUID()
    var date: Date
  }
  
  func fetchWeek(_ date: Date = Date()) -> [WeekDay] {
    let calendar = Calendar.current
    let startOfDate = calendar.startOfDay(for: date)
    
    var week: [WeekDay] = []
    let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
    
    guard let startOfWeek = weekForDate?.start else {
      return []
    }
    
    (0..<7).forEach { index in
      if let weekDay = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
        week.append(.init(date: weekDay))
      }
    }
    
    return week
  }
  
  func createPrevWeek() -> [WeekDay] {
    let calendar = Calendar.current
    let startOfFirstDate = calendar.startOfDay(for: self)
    
    guard let prevDate = calendar.date(byAdding: .day, value: -1, to: startOfFirstDate) else {
      return []
    }
    
    return fetchWeek(prevDate)
  }
  
  func createNextWeek() -> [WeekDay] {
    let calendar = Calendar.current
    let startOfLastDate = calendar.startOfDay(for: self)
    
    guard let nextDate = calendar.date(byAdding: .day, value: 1, to: startOfLastDate) else {
      return []
    }
    
    return fetchWeek(nextDate)
  }
}
