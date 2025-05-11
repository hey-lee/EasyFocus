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
  @State var showTimerView: Bool = false
  
  init() {
    Tools.transparentNavBar()
    Tools.transparentTabBar()
  }
  
  var body: some View {
    FocusView()
      .overlay {
        VStack {
          Spacer()
          HStack {
            Spacer()
            Symbol("sf.timer", colors: [.slate50])
              .onTapGesture {
                showTimerView = true
              }
          }
          .padding()
          .padding(.bottom, 40)
        }
      }
      .sheet(isPresented: $showTimerView) {
        TimerView()
      }
  }
}

#Preview {
  ContentView()
    .environment(FocusKit())
    .environmentObject(NavKit())
    .environmentObject(Stackit())
    .modelContainer(for: [])
}
