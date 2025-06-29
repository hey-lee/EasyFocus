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
      .init(key: "focus.short.breaks", name: "short.break", icon: "", foregroundColor: Color.slate700, type: .sheet),
      .init(key: "focus.long.breaks", name: "long.break", icon: "", foregroundColor: Color.slate700, type: .sheet),
      .init(key: "focus.sessions.per.round", name: "focus.sessions.per.round", icon: "", foregroundColor: Color.slate700, type: .sheet),
      .init(key: "auto.start.short.breaks", name: "auto.start.short.breaks", icon: "", foregroundColor: Color.slate700, type: .toggle),
      .init(key: "auto.start.sessions", name: "auto.start.sessions", icon: "", foregroundColor: Color.slate700, type: .toggle),
      .init(key: "focus.reminder", name: "reminder", icon: "sf.bell.fill", foregroundColor: Color.slate700, type: .toggle),
    ]),
    (name: "Data & Security", items: [
      .init(key: "icloud.sync", name: "icloud.sync", icon: "sf.icloud.and.arrow.up", foregroundColor: Color.slate700, trailingText: DBKit.shared.iCloudSyncStatus),
      .init(key: "calendar.sync", name: "calendar.sync", icon: "sf.icloud.and.arrow.up", foregroundColor: Color.slate700, type: .toggle),
      .init(key: "app.whitelist", name: "app.whitelist", icon: "sf.icloud.and.arrow.up", foregroundColor: Color.slate700, type: .sheet),
    ]),
    (name: "App Settings", items: [
//      .init(key: "theme", name: "theme", icon: "", foregroundColor: Color.slate700),
      .init(key: "app.icons", name: "app.icons", icon: "", foregroundColor: Color.slate700),
      .init(key: "language", name: "language", icon: "", foregroundColor: Color.slate700),
      .init(key: "feedback.haptic", name: "haptic", icon: "haptic", foregroundColor: Color.slate700, type: .toggle),
//      .init(key: "feedback.sound", name: "tap.sound", icon: "sound", foregroundColor: Color.slate700, type: .toggle),
    ]),
  ]
}
