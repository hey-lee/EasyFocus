//
//  CodableModels.swift
//  EasyFocus
//
//  Created by DBL on 2025/7/2.
//

import Foundation

class C {
  struct Focus: Identifiable, Equatable, Codable {
    var id: String
    var minutes: Int
    var sessionsCount: Int
    var completedSecondsCount: Int
    var completedSessionsCount: Int
    var restShort: Int
    var restLong: Int
    var notes: String
    var calendarEventID: String
    var label: FocusLabel?
    var startedAt: Date
    var endedAt: Date
    var createdAt: Date
  }
  
  struct FocusLabel: Identifiable, Equatable, Codable {
    var id: String
    var name: String
    var icon: String
    var backgroundColor: String
    var focuses: [Focus] = []
  }
}
