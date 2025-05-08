//
//  TimerView.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/3.
//

import SwiftUI

struct TimerView: View {
  @Environment(FocusService.self) var focusService
  
  var body: some View {
    PageView {
      HStack {
        Group {
          Text(focusService.display.minutes)
          VStack {
            Circle()
              .frame(width: 20, height: 20)
            Circle()
              .frame(width: 20, height: 20)
          }
          Text(focusService.display.seconds)
        }
        .tracking(-4)
        .font(.custom("Code Next ExtraBold", size: UIDevice.current.orientation.isLandscape ? 200 : 100).monospacedDigit())
      }
      
      Group {
        HStack {
          let symbolName = switch focusService.sm.state {
          case .idle, .paused: "play.fill"
          case .running: "pause.fill"
          }
          Symbol("sf.\(symbolName)", colors: [.slate200], contentSize: .small)
            .onTapGesture {
              withAnimation {
                switch focusService.sm.state {
                case .idle:
                  focusService.start()
                case .running:
                  focusService.pause()
                case .paused:
                  focusService.resume()
                }
              }
            }
          Symbol("sf.stop.fill", colors: [.slate200], contentSize: .small)
            .onTapGesture {
              withAnimation {
                focusService.stop()
              }
            }
//          Symbol("sf.bell.badge.fill", colors: [.slate200], contentSize: .small)
//            .onTapGesture {
//              Task {
//                _ = await NotificationService.shared.requestAuthorization()
//              }
//            }
        }
        VStack(alignment: .leading, spacing: 8) {
          Toggle("Auto start sessions", isOn: .init(get: {
            focusService.settings.autoStartSessions
          }, set: { value in
            focusService.settings.autoStartSessions = value
          }))
          Toggle("Auto start short break", isOn: .init(get: {
            focusService.settings.autoStartShortBreaks
          }, set: { value in
            focusService.settings.autoStartShortBreaks = value
          }))
          Row("Timer state") {
            Text("\(focusService.sm.state)")
          }
          Row("Timer minutes") {
            Text("\(focusService.settings.minutes)")
          }
          Row("Timer seconds") {
            Text("\(focusService.duration) (\(focusService.sm.mode))")
          }
          Row("Timer break type") {
            Text("\(focusService.sessions.breakType)")
          }
          Row("Short break minutes") {
            Text("\(focusService.settings.shortBreakMinutes)")
          }
          Row("Long break minutes") {
            Text("\(focusService.settings.longBreakMinutes)")
          }
          Row("Total sessions count") {
            Text("\(focusService.sessions.totalCount)")
          }
          Row("Completed cessions count") {
            Text("\(focusService.sessions.completedCount)")
          }
          Row("Remaining seconds") {
            Text("\(focusService.timer.remainingSeconds)")
          }
          Row("Total seconds") {
            Text("\(focusService.seconds.total)")
          }
          Row("Total remaining seconds") {
            Text("\(focusService.totalRemainingSeconds)")
          }
          Row("Schedule seconds") {
            Text("\(focusService.scheduleSeconds)")
          }
          Row("Background seconds") {
            Text("\(focusService.seconds.background)s")
          }
        }
      }
      .buttonStyle(.borderedProminent)
    }
    .onChange(of: focusService.mode) { oldValue, newValue in
      print("mode", newValue)
    }
  }
  
  @ViewBuilder
  func Row(_ label: String, @ViewBuilder value: @escaping () -> some View = { EmptyView() }) -> some View {
    let width = UIScreen.main.bounds.width - 32
    let leftWidth = width / 3 * 2
    let rightWidth = width / 3
    HStack {
      HStack {
        Text(label)
        Spacer()
      }
      .frame(width: leftWidth)
      HStack {
        value()
        Spacer()
      }
      .frame(width: rightWidth)
    }
  }
}

#Preview {
  TimerView()
    .environment(FocusService())
}
