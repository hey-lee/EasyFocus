//
//  Models.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/24.
//

import SwiftData
import Foundation

// Codable structs
class C {
  struct TagLabel: Decodable, Identifiable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var icon: String
    var backgroundColor: String = ""
  }
}

@Model
class Focus {
  var minutes: Int
  var sessionsCount: Int
  var completedMinutesCount: Int
  var completedSessionsCount: Int
  var restShort: Int
  var restLong: Int
  var label: C.TagLabel
  var createdAt: Date
  
  init(
    minutes: Int,
    sessionsCount: Int,
    completedMinutesCount: Int,
    completedSessionsCount: Int,
    restShort: Int,
    restLong: Int,
    label: C.TagLabel,
    createdAt: Date = Date()
  ) {
    self.minutes = minutes
    self.sessionsCount = sessionsCount
    self.completedMinutesCount = completedMinutesCount
    self.completedSessionsCount = completedSessionsCount
    self.restShort = restShort
    self.restLong = restLong
    self.label = label
    self.createdAt = createdAt
  }
}
