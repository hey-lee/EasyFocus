//
//  ContentView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import SwiftData

enum Route {
  case Stats, StatsWeb, Home, Settings
}

struct ContentView: View {
  @EnvironmentObject var nav: NavKit
  @EnvironmentObject var stack: Stackit
  @EnvironmentObject var show: ShowKit
  @State var showTimerView: Bool = false
  @State var activeRoute: Route = Route.Home
  
  init() {
    Tools.transparentNavBar()
    Tools.transparentPageIndicator()
  }
  
  var body: some View {
    TabView(selection: $activeRoute) {
      StatsView()
        .tag(Route.Stats)
      StatsWebView()
        .tag(Route.StatsWeb)
      
      FocusView()
        .tag(Route.Home)
        .padding(.top, 8)
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
      
      SettingsView()
        .tag(Route.Settings)
    }
    .fullScreenCover(isPresented: $show.ProView) {
      ProductsView()
    }
    .ignoresSafeArea()
    .tabViewStyle(.page)
    .overlay {
      if show.WheelSliderView {
        WheelSliderView()
      }
    }
  }
}

#Preview {
  ContentView()
    .environment(DBKit())
    .environment(TagsKit())
    .environment(FocusKit())
    .environment(FocusService())
    .environment(ModalKit.shared)
    .environmentObject(NavKit())
    .environmentObject(ShowKit())
    .environmentObject(Stackit())
    .modelContainer(for: [
      Focus.self,
    ])
}
