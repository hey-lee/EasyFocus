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
      .init(key: "start.date", name: "start", icon: "calendar-day", colors: [Color.fuchsia300]),
      .init(key: "quick", name: "quick", icon: "rabbit-running", colors: [Color.pink300], type: .toggle),
    ]),
    (name: "Data & Security", items: [
      .init(key: "icloud", name: "icloud", icon: "sf.icloud.and.arrow.up", colors: [Color.emerald300]),
      .init(key: "clear.data", name: "clear.data", icon: "sf.paintbrush", colors: [Color.emerald300]),
    ]),
    (name: "App Settings", items: [
      .init(key: "general", name: "general", icon: "gear", colors: [Color.rose300]),
      .init(key: "password", name: "password", icon: "sf.key", colors: [Color.rose300]),
      .init(key: "theme", name: "theme", icon: "palette", colors: [Color.yellow300]),
      .init(key: "app.icons", name: "app.icons", icon: "palette", colors: [Color.yellow300]),
      .init(key: "language", name: "language", icon: "palette", colors: [Color.yellow300]),
      .init(key: "inactive.blur", name: "inactive.blur", icon: "", colors: [Color.yellow300], type: .toggle),
      .init(key: "feedback.haptic", name: "haptic", icon: "haptic", colors: [Color.lime300], type: .toggle),
      .init(key: "feedback.sound", name: "tap.sound", icon: "sound", colors: [Color.lime300], type: .toggle),
    ]),
  ]
}
