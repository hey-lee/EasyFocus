//
//  Models.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/24.
//

import SwiftData
import Foundation

@Model
class Focus {
  var minutes: Int = 25
  var sessionsCount: Int = 4
  var completedSecondsCount: Int = 0
  var completedSessionsCount: Int = 0
  var restShort: Int = 5
  var restLong: Int = 20
  var notes: String = ""
  var calendarEventID: String = ""
  var label: FocusLabel?
  var startedAt: Date = Date()
  var endedAt: Date = Date()
  var createdAt: Date = Date()
  var description: String {
"""
Focus(
  minutes: \(minutes),
  sessionsCount: \(sessionsCount),
  completedSecondsCount: \(completedSecondsCount),
  completedSessionsCount: \(completedSessionsCount),
  label: \(label?.name ?? ""),
  notes: \(notes),
  calendarEventID: \(calendarEventID),
  startedAt: \(startedAt.format()),
  endedAt: \(endedAt.format()),
  createdAt: \(createdAt.format()),
)
"""
  }
  
  init(
    minutes: Int = 25,
    sessionsCount: Int = 4,
    completedSecondsCount: Int = 0,
    completedSessionsCount: Int = 0,
    restShort: Int = 5,
    restLong: Int = 20,
    notes: String = "",
    calendarEventID: String = "",
    label: FocusLabel?,
    startedAt: Date = Date(),
    endedAt: Date = Date(),
    createdAt: Date = Date()
  ) {
    self.minutes = minutes
    self.sessionsCount = sessionsCount
    self.completedSecondsCount = completedSecondsCount
    self.completedSessionsCount = completedSessionsCount
    self.restShort = restShort
    self.restLong = restLong
    self.notes = notes
    self.calendarEventID = calendarEventID
    self.label = label
    self.startedAt = startedAt
    self.endedAt = endedAt
    self.createdAt = createdAt
  }
}

@Model
class FocusLabel {
  var id: String = UUID().uuidString
  var name: String = ""
  var icon: String = ""
  var backgroundColor: String = ""
  @Relationship(inverse: \Focus.label)
  var focuses: [Focus]? = []
  
  init(
    id: String = UUID().uuidString,
    name: String = "",
    icon: String = "",
    backgroundColor: String = "",
    focuses: [Focus]? = []
  ) {
    self.id = id
    self.name = name
    self.icon = icon
    self.backgroundColor = backgroundColor
    self.focuses = focuses
  }
}
