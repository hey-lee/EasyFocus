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
  var minutes: Int
  var sessionsCount: Int
  var completedMinutesCount: Int
  var completedSessionsCount: Int
  var restShort: Int
  var restLong: Int
  var label: Tag
  var createdAt: Date
  
  init(
    minutes: Int,
    sessionsCount: Int,
    completedMinutesCount: Int,
    completedSessionsCount: Int,
    restShort: Int,
    restLong: Int,
    label: Tag,
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

@Model
class Tag {
  var id: String
  var name: String
  var icon: String
  var backgroundColor: String
  
  init(
    id: String = UUID().uuidString,
    name: String,
    icon: String,
    backgroundColor: String = ""
  ) {
    self.id = id
    self.name = name
    self.icon = icon
    self.backgroundColor = backgroundColor
  }
}
