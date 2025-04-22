//
//  ContentView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  
  var body: some View {
    FocusView()
  }
}

#Preview {
  ContentView()
    .environment(FocusKit())
    .modelContainer(for: [])
}
