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
  @AppStorage("mode") var isDark = false
  @AppStorage("isAuth") var isAuth: Bool = true
  @AppStorage("quickMode") var quickMode: Bool = true
  @AppStorage("enableSound") var enableSound = true
  @AppStorage("enableHapic") var enableHaptic = true
  @AppStorage("amountColorIndex") var amountColorIndex = 0
  @AppStorage("enableInactiveBlur") var enableInactiveBlur = false
  
  // @State
  @State var isTouched = false
  @State var touchingKey: String = ""
  @State var showAmountColorsOverlay: Bool = false
  
  init() {
//    Tools.transparentNavBar()
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
              case "quick":
                CellView(cell: cell, isOn: $quickMode)
              case "feedback.haptic":
                CellView(cell: cell, isOn: $enableHaptic)
              case "feedback.sound":
                CellView(cell: cell, isOn: $enableSound)
              case "inactive.blur":
                CellView(cell: cell, isOn: $enableInactiveBlur)
              default:
                EmptyView()
              }
              
            case .sheet:
              switch cell.key {
              default:
                EmptyView()
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
    .onChange(of: quickMode, { _, _ in
      UserDefaults.standard.set(quickMode, forKey: "quickMode")
    })
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
