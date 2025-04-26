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
  
  init() {
    Tools.transparentNavBar()
    Tools.transparentTabBar()
  }
  
  var body: some View {
    FocusView()
      .tag(NavKit.NavType.focus)
  }
}

#Preview {
  ContentView()
    .environment(FocusKit())
    .environmentObject(NavKit())
    .environmentObject(Stackit())
    .modelContainer(for: [])
}
