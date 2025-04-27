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
      .init(key: "focus.short.breaks", name: "short.break", icon: "", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "focus.long.breaks", name: "long.break", icon: "", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "focus.sessions.per.round", name: "focus.sessions.per.round", icon: "", colors: [Color.fuchsia300], type: .sheet),
      .init(key: "auto.start.short.breaks", name: "auto.start.short.breaks", icon: "", colors: [Color.fuchsia300], type: .toggle),
      .init(key: "auto.start.sessions", name: "auto.start.sessions", icon: "", colors: [Color.fuchsia300], type: .toggle),
      .init(key: "focus.reminder", name: "reminder", icon: "sound", colors: [Color.lime300], type: .toggle),
    ]),
    (name: "Data & Security", items: [
      .init(key: "icloud.sync", name: "icloud.sync", icon: "sf.icloud.and.arrow.up", colors: [Color.emerald300], trailingText: DBKit.shared.iCloudSyncStatus),
      .init(key: "calendar.sync", name: "calendar.sync", icon: "sf.icloud.and.arrow.up", colors: [Color.lime300], type: .toggle),
      .init(key: "app.whitelist", name: "app.whitelist", icon: "sf.icloud.and.arrow.up", colors: [Color.lime300], type: .toggle),
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
