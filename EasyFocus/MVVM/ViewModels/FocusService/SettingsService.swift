//
//  SettingsService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import SwiftUI

struct SettingsService {
  static let shared = SettingsService()

  @AppStorage("minutes") var minutes: Int = 20
  @AppStorage("sessionsCount") var sessionsCount: Int = 4
  @AppStorage("shortBreak") var shortBreak: Int = 5
  @AppStorage("longBreak") var longBreak: Int = 15
  @AppStorage("autoStartSessions") var autoStartSessions: Bool = false
  @AppStorage("autoStartShortBreaks") var autoStartShortBreaks: Bool = false
}
