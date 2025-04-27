//
//  SettingsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
  @Query var focuses: [Focus]
  
  @Environment(\.modelContext) var context
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var show: ShowKit
  @EnvironmentObject var stack: Stackit
  
  // @AppStorage
  // focus
  @AppStorage("enableReminder") var enableReminder: Bool = false
  @AppStorage("autoStartSessions") var autoStartSessions: Bool = false
  @AppStorage("enableCalendarSync") var enableCalendarSync: Bool = false
  @AppStorage("autoStartShortBreaks") var autoStartShortBreaks: Bool = false
  @AppStorage("minutes") var minutes: Int = 25
  @AppStorage("restShort") var restShort: Int = 5
  @AppStorage("restLong") var restLong: Int = 15
  @AppStorage("sessionsCount") var sessionsCount: Int = 4
  // app settings
  @AppStorage("mode") var isDark = false
  @AppStorage("enableSound") var enableSound = true
  @AppStorage("enableHapic") var enableHaptic = true
  @AppStorage("whitelistMode") var whitelistMode = "loose"
  @AppStorage("enableAppWhitelist") var enableAppWhitelist = true
  
  // @State
  @State var isTouched = false
  @State var touchingKey: String = ""
  @State var showAmountColorsOverlay: Bool = false
  @State var selection = FamilyActivitySelection()
  
  init() {
    Tools.transparentNavBar()
  }
  
  var body: some View {
    PageView {
      ForEach(Array(zip(SettingsKit.shared.sections.indices, SettingsKit.shared.sections)), id: \.0) { index, section in
        //        VStack {
        //          HStack {
        //            Text(section.name)
        //              .textCase(.uppercase)
        //              .font(.title2.weight(.heavy))
        //              .foregroundColor(ThemeKit.theme.foregroundColor)
        //            Spacer()
        //          }
        //        }
        LazyVStack(spacing: 0) {
          ForEach(section.items) { cell in
            switch cell.type {
            case .toggle:
              switch cell.key {
              case "auto.start.short.breaks":
                CellView(cell: cell, isOn: $autoStartShortBreaks)
              case "auto.start.sessions":
                CellView(cell: cell, isOn: $autoStartSessions)
              case "focus.reminder":
                CellView(cell: cell, isOn: $enableReminder)
              case "feedback.haptic":
                CellView(cell: cell, isOn: $enableHaptic)
              case "feedback.sound":
                CellView(cell: cell, isOn: $enableSound)
              case "calendar.sync":
                CellView(cell: cell, isOn: $enableCalendarSync)
              case "app.whitelist":
                VStack {
                  CellView(cell: cell, isOn: $enableAppWhitelist)
                  if enableAppWhitelist {
                    SegmentedView(selection: $whitelistMode, segments: [
                      (key: "strict", name: "Strict Mode"),
                      (key: "whitelist", name: "Whitelist Mode"),
                      (key: "loose", name: "Loose Mode"),
                    ])
                    .animation(.snappy, value: whitelistMode)
                    .border(.black)
                  }
                }
              default:
                EmptyView()
              }
              
            case .sheet:
              switch cell.key {
              case "focus.short.breaks":
                CellView(cell: cell, trailingText: "\(restShort.description)m")
                  .onTapGesture {
                    show.shortBreakSheetView = true
                  }
              case "focus.long.breaks":
                CellView(cell: cell, trailingText: "\(restLong.description)m")
                  .onTapGesture {
                    show.longBreakSheetView = true
                  }
              case "focus.sessions.per.round":
                CellView(cell: cell, trailingText: sessionsCount.description)
                  .onTapGesture {
                    show.sessionsCountSheetView = true
                  }
              default:
                CellView(cell: cell)
              }
              
            default:
              CellView(cell: cell)
                .onTapGesture {
                  Tools.haptic()
                  switch cell.key {
                  case "language":
                    Tools.openAppSettings()
                  default:
                    stack.settings.append(cell.key)
                  }
                }
              //                .buttonStyle(.plainLink)
                .onLongPressGesture {
                  print("onpress")
                } onPressingChanged: { isPending in
                  withAnimation(.bouncy) {
                    isTouched = isPending
                    touchingKey = cell.key
                  }
                }
                .scaledToFit()
                .scaleEffect(CGSize(width: isTouched && touchingKey == cell.key ? 0.97 : 1, height: isTouched && touchingKey == cell.key ? 0.97 : 1))
            }
          }
        }
        .padding(.vertical)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: ThemeKit.theme.backgroundColor, radius: CGFloat(24), x: 0, y: CGFloat(24))
      }
    }
    .toolbar(.hidden, for: .tabBar)
    .sheet(isPresented: $show.shortBreakSheetView) {
      VStack {
        Text(restShort.description)
      }
      .presentationDetents([
        //        .medium,
        .height(320),
      ])
    }
    .sheet(isPresented: $show.longBreakSheetView) {
      VStack {
        Text(restLong.description)
      }
      .presentationDetents([
        //        .medium,
        .height(320),
      ])
    }
    .sheet(isPresented: $show.sessionsCountSheetView) {
      VStack {
        Text(sessionsCount.description)
      }
      .presentationDetents([
        //        .medium,
        .height(320),
      ])
    }
    .familyActivityPicker(isPresented: $show.FamilyActivityPicker, selection: $selection)
    .onChange(of: selection, { _, selection in
      AppControlsKit.shared.updateApplicationTokens(selection.applicationTokens)
    })
    .onChange(of: enableAppWhitelist, { _, enableAppWhitelist in
      if enableAppWhitelist {
        AppControlsKit.shared.requestAuthorization()
      } else {
        AppControlsKit.shared.stopAppShield()
      }
    })
    .onChange(of: whitelistMode, { _, whitelistMode in
      if whitelistMode == "whitelist" {
        show.FamilyActivityPicker = true
      }
    })
    .onChange(of: enableHaptic, { _, enableHaptic in
      UserDefaults.standard.set(enableHaptic, forKey: "enableHaptic")
    })
    .onChange(of: enableCalendarSync, { _, enableCalendarSync in
      if enableCalendarSync {
        Task {
          await syncToCalendar()
        }
      }
    })
    .navigationTitle("Settings")
  }
  
  func syncToCalendar() async {
    do {
      let granted = try await CalendarKit.shared.requestAccess()
      guard granted else {
        return
      }
      
      for focus in focuses {
        if focus.calendarEventID.isEmpty {
          let id = try await CalendarKit.shared.addFocusToCalendar(focus)
          focus.calendarEventID = id
          try context.save()
        }
      }
    } catch {
      print("syncToCalendar error:", error.localizedDescription)
    }
  }
}

#Preview {
  SettingsView()
    .environment(DBKit())
    .environmentObject(ShowKit())
    .environmentObject(Stackit())
}
