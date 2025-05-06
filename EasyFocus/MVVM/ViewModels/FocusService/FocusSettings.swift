//
//  SettingsService.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import SwiftUI

struct FocusSettings {
  static let shared = FocusSettings()

  @AppStorage("minutes") var minutes: Int = 20
  @AppStorage("shortBreak") var shortBreakMinutes: Int = 1
  @AppStorage("longBreak") var longBreakMinutes: Int = 3
  @AppStorage("sessionsCount") var sessionsCount: Int = 4
  @AppStorage("autoStartSessions") var autoStartSessions: Bool = false
  @AppStorage("autoStartShortBreaks") var autoStartShortBreaks: Bool = false
}
