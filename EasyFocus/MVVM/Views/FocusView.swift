//
//  HomeView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import Shimmer

struct FocusView: View {
  @Environment(\.modelContext) var context
  @Environment(DBKit.self) var db
  @Environment(TagsKit.self) var tagsKit
  @Environment(FocusKit.self) var focusKit
  @EnvironmentObject var nav: NavKit
  @EnvironmentObject var show: ShowKit
  @EnvironmentObject var stack: Stackit

  @AppStorage("enableCalendarSync") var enableCalendarSync = false
  
  var body: some View {
    NavigationStack(path: $stack.settings) {
      VStack {
        VStack(spacing: 0) {
          focusView
          
          if focusKit.state == .running, !focusKit.isForwardMode {
            sessionsView
          }
          if focusKit.state == .idle, focusKit.mode == .work, focusKit.sessionIndex == 0 {
            tagView
          }
        }
        
        if focusKit.state == .idle {
          Text(focusKit.mode == .work ? "Start Focus" : "Take a rest")
            .font(.custom("Code Next ExtraBold", size: 18))
            .foregroundStyle(.white)
            .padding()
            .background(.black)
            .clipShape(Capsule())
            .onTapGesture {
              Tools.haptic()
              focusKit.createFocusModel()
              withAnimation {
                focusKit.start()
                AppControlsKit.shared.startAppShield()
              }
            }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbar {
        if focusKit.state == .idle {
          ToolbarItem(placement: .topBarLeading) {
            Symbol("sf.chart.bar.fill")
              .onTapGesture {
                // stack.settings.append("stats")
                show.StatsView = true
              }
          }
          ToolbarItem(placement: .topBarTrailing) {
            Symbol("sf.ellipsis")
              .onTapGesture {
                stack.settings.append("settings")
              }
          }
        }
      }
      .overlay {
        if focusKit.state == .running {
          LongTapView {
            withAnimation {
              focusKit.updateFocusModel()
              if let focus = focusKit.focus {
                Task {
                  do {
                    if enableCalendarSync {
                      focus.calendarEventID = try await CalendarKit.shared.addFocusToCalendar(focus)
                    }
                    context.insert(focus)
                    try context.save()
                    print("focus.saved")
                  } catch let error {
                    print("focus model save error", error)
                  }
                }
              }
              if focusKit.isForwardMode {
                self.focusKit.stop()
              } else {
                if self.focusKit.percent != 0 {
                  self.focusKit.stop()
                }
              }
            }
          }
        }
      }
      .overlay {
        if show.WheelSliderView {
          WheelSliderView()
        }
      }
      .sheet(isPresented: $show.tags) {
        TagsView()
          .presentationDetents([
            .medium,
          ])
          .presentationDragIndicator(.visible)
          .presentationCornerRadius(32)
      }
      .fullScreenCover(isPresented: $show.StatsView) {
        StatsView()
      }
      .onChange(of: tagsKit.modelLabel) { oldValue, newValue in
        if let label = tagsKit.modelLabel, let focus = focusKit.focus {
          focus.label = label
        }
      }
      .navigationDestination(for: String.self) { key in
        switch key {
        case "stats":
          StatsView()
        case "settings":
          SettingsView()
        case "icloud":
          PageView {
            Text("Settings")
            Toggle(isOn: .init(get: {
              UserDefaults.standard.bool(forKey: "enableiCloudSync")
            }, set: { enableiCloudSync in
              UserDefaults.standard.set(enableiCloudSync, forKey: "enableiCloudSync")
            })) {
              Text("iCloud Sync")
            }
            Text("iCloud: \(db.iCloudStatus)")
            Text("iCloud sync status: \(db.iCloudSyncStatus)")
            if let lastSyncTime = db.lastSyncTime {
              Text("iCloud last sync time: \(Tools.format(lastSyncTime))")
            }
            Button("打开系统设置") {
              if let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
            .buttonStyle(.borderedProminent)
          }
        default:
          PageView()
        }
      }
    }
  }
  
  var focusView: some View {
    HStack(spacing: 8) {
      Group {
        Text(focusKit.display.minutes)
        VStack {
          let size: CGFloat = focusKit.state != .idle ? 20 : 16
          Circle()
            .frame(width: size, height: size)
          Circle()
            .frame(width: size, height: size)
        }
        Text(focusKit.display.seconds)
      }
      .tracking(-4)
      .font(.custom("Code Next ExtraBold", size: UIDevice.current.orientation.isLandscape ? 200 : (focusKit.state == .idle) ? 80 : 100).monospacedDigit())
    }
    .onTapGesture {
      Tools.haptic()
      withAnimation {
        if focusKit.state == .idle {
          show.WheelSliderView = true
        }
      }
    }
  }
  
  @ViewBuilder
  var tagView: some View {
    if let label = tagsKit.modelLabel {
      HStack {
        Text(label.name)
          .font(.custom("Code Next ExtraBold", size: 24))
        Image(systemName: "chevron.compact.right")
      }
      .onTapGesture {
        show.tags = true
      }
    }
  }
  
  var sessionsView: some View {
    HStack(spacing: 16) {
      ForEach(0...focusKit.sessionsCount - 1, id: \.self) { index in
        ZStack {
          Circle()
            .stroke(Color.black, lineWidth: 4)
            .frame(width: 20, height: 20)
          Circle()
            .trim(from: 0, to: focusKit.getSessionProgress(index))
            .stroke(Color.black, lineWidth: 10)
            .frame(width: 10, height: 10)
            .animation(.linear(duration: 0.5), value: focusKit.percent)
        }
      }
    }
    .padding()
  }
}

#Preview {
  FocusView()
    .environment(DBKit())
    .environment(TagsKit())
    .environment(FocusKit())
    .environmentObject(NavKit())
    .environmentObject(ShowKit())
    .environmentObject(Stackit())
    .modelContainer(for: [
      Focus.self,
    ])
}
