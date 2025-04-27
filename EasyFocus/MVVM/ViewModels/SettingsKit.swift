//
//  SettingsKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

@Observable
final class SettingsKit {
  static let shared = SettingsKit()
  
  var sections: [(name: String, items: [CellView.Cell])] = [
    (name: "Preferences", items: [
      .init(key: "focus.short.breaks", name: "short.breaks", icon: "calendar-day", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "focus.long.breaks", name: "long.breaks", icon: "calendar-day", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "focus.sessions.per.round", name: "focus.sessions.per.round", icon: "calendar-day", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "auto.start.short.breaks", name: "auto.start.short.breaks", icon: "calendar-day", colors: [Color.fuchsia300], type: .toggle),
      .init(key: "auto.start.sessions", name: "auto.start.sessions", icon: "calendar-day", colors: [Color.fuchsia300], type: .toggle),
      .init(key: "focus.reminder", name: "reminder", icon: "sound", colors: [Color.lime300], type: .toggle),
    ]),
    (name: "Data & Security", items: [
      .init(key: "icloud", name: "icloud", icon: "sf.icloud.and.arrow.up", colors: [Color.emerald300], trailingText: DBKit.shared.iCloudSyncStatus),
    ]),
    (name: "App Settings", items: [
      .init(key: "theme", name: "theme", icon: "palette", colors: [Color.yellow300]),
      .init(key: "app.icons", name: "app.icons", icon: "palette", colors: [Color.yellow300]),
      .init(key: "language", name: "language", icon: "palette", colors: [Color.yellow300]),
      .init(key: "feedback.haptic", name: "haptic", icon: "haptic", colors: [Color.lime300], type: .toggle),
      .init(key: "feedback.sound", name: "tap.sound", icon: "sound", colors: [Color.lime300], type: .toggle),
    ]),
  ]
}
