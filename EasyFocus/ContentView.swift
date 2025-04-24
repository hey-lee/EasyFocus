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
  
  var body: some View {
    TabView(selection: $nav.activeTab) {
      FocusView()
        .tag("focus")
      VStack {
        Text("settings")
      }
        .tag("settings")
    }
    .tabViewStyle(.page)
  }
}

#Preview {
  ContentView()
    .environment(FocusKit())
    .environmentObject(NavKit())
    .modelContainer(for: [])
}
