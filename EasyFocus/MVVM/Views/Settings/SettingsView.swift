//
//  SettingsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var stack: Stackit
  @Environment(\.dismiss) var dismiss
  
  // @AppStorage
  // focus
  @AppStorage("autoRun") var autoRun: Bool = true
  @AppStorage("minutes") var minutes: Int = 25
  @AppStorage("sessionsCount") var sessionsCount: Int = 4
  @AppStorage("restShort") var restShort: Int = 5
  @AppStorage("restLong") var restLong: Int = 15
  // app settings
  @AppStorage("mode") var isDark = false
  @AppStorage("enableSound") var enableSound = true
  @AppStorage("enableHapic") var enableHaptic = true
  
  // @State
  @State var isTouched = false
  @State var touchingKey: String = ""
  @State var showAmountColorsOverlay: Bool = false
  
  init() {
    Tools.transparentNavBar()
  }
  
  var body: some View {
    PageView {
      ForEach(Array(zip(SettingsKit.shared.sections.indices, SettingsKit.shared.sections)), id: \.0) { index, section in
        VStack {
          HStack {
            Text(section.name)
              .textCase(.uppercase)
              .font(.title2.weight(.heavy))
              .foregroundColor(ThemeKit.theme.foregroundColor)
            Spacer()
          }
        }
        LazyVStack(spacing: 0) {
          ForEach(section.items) { cell in
            switch cell.type {
            case .toggle:
              switch cell.key {
              case "auto.start.short.breaks":
                CellView(cell: cell, isOn: $autoRun)
              case "auto.start.long.breaks":
                CellView(cell: cell, isOn: $autoRun)
              case "focus.reminder":
                CellView(cell: cell, isOn: $autoRun)
              case "feedback.haptic":
                CellView(cell: cell, isOn: $enableHaptic)
              case "feedback.sound":
                CellView(cell: cell, isOn: $enableSound)
              default:
                EmptyView()
              }
              
            case .sheet:
              switch cell.key {
              case "focus.minutes":
                CellView(cell: cell, trailingText: "\(minutes.description)m")
              case "focus.short.breaks":
                CellView(cell: cell, trailingText: "\(restShort.description)m")
              case "focus.long.breaks":
                CellView(cell: cell, trailingText: "\(restLong.description)m")
              case "focus.sessions.per.round":
                CellView(cell: cell, trailingText: sessionsCount.description)
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
    .onChange(of: enableHaptic, { _, enableHaptic in
      UserDefaults.standard.set(enableHaptic, forKey: "enableHaptic")
    })
    .navigationTitle("Settings")
  }
}

#Preview {
  SettingsView()
    .environment(DBKit())
    .environmentObject(Stackit())
}
