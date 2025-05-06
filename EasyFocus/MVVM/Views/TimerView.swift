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
      HStack(spacing: 8) {
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
          Button("Start Work") {
            focusService.start()
          }
          Button("Start Rest") {
            focusService.start(.rest)
          }
          Button("Pause") {
            focusService.pause()
          }
          Button("Resume") {
            focusService.resume()
          }
          Button("Stop") {
            focusService.stop()
          }
        }
        HStack {
          Button("Request Notification") {
            Task {
              _ = await NotificationService.shared.requestAuthorization()
            }
          }
        }
        VStack(alignment: .leading) {
          Text("\(focusService.getSessionsCount(by: 18))")
          Text("Timer state: \(focusService.sm.state)")
          Text("Timer minutes: \(focusService.settings.minutes)")
          Text("Timer seconds: \(focusService.duration) (\(focusService.sm.mode))")
          Text("Timer break type: \(focusService.breakType)")
          Text("Short break minutes: \(focusService.settings.shortBreakMinutes)")
          Text("Long break minutes: \(focusService.settings.longBreakMinutes)")
          Text("Total sessions count: \(focusService.settings.sessionsCount)")
          Text("Completed cessions count: \(focusService.completedSessionsCount)")
          Text("Remaining seconds: \(focusService.timer.remainingSeconds)")
          Text("Total seconds: \(focusService.totalSeconds)")
          Text("Total remaining seconds: \(focusService.remainingTotalSeconds)")

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
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  TimerView()
    .environment(FocusService())
}
