//
//  ContentView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @EnvironmentObject var nav: NavKit
  @EnvironmentObject var stack: Stackit
  
  var body: some View {
    TabView(selection: $nav.activeNav) {
//      StatsView()
//        .tag(NavKit.NavType.stats)
      FocusView()
        .tag(NavKit.NavType.focus)
//      SettingsView()
//        .tag(NavKit.NavType.settings)
    }
    .tabViewStyle(.page)
  }
}

#Preview {
  ContentView()
    .environment(FocusKit())
    .environmentObject(NavKit())
    .environmentObject(Stackit())
    .modelContainer(for: [])
}
