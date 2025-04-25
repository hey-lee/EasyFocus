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
  var completedMinutesCount: Int = 0
  var completedSessionsCount: Int = 0
  var restShort: Int = 5
  var restLong: Int = 20
  var label: FocusLabel?
  var createdAt: Date = Date()
  
  init(
    minutes: Int,
    sessionsCount: Int,
    completedMinutesCount: Int,
    completedSessionsCount: Int,
    restShort: Int,
    restLong: Int,
    label: FocusLabel?,
    createdAt: Date
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
