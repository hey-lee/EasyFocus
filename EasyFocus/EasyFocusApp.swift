//
//  EasyFocusApp.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import SwiftData

@main
struct EasyFocusApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .environment(FocusKit())
    .environment(TagsKit.shared)
    .environmentObject(ShowKit())
    .modelContainer(for: [])
  }
}
