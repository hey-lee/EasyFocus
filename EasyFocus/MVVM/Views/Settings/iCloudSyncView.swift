//
//  iCloudSyncView.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/12.
//

import SwiftUI

struct iCloudSyncView: View {
  @Environment(DBKit.self) var db
  
  var sections: [(name: String, items: [CellView.Cell])] = [
    (name: "", items: [
      .init(key: "enable.icloud.sync", name: "enable.icloud.sync", icon: "", colors: [Color.fuchsia300], type: .toggle),
    ]),
    (name: "", items: [
      .init(key: "network", name: "network", icon: "", type: .normal, showChevron: false),
      .init(key: "icloud", name: "icloud", icon: "", type: .normal, showChevron: false),
      .init(key: "sync.status", name: "sync.status", icon: "", type: .normal, showChevron: false),
      .init(key: "icloud.last.sync.time", name: "icloud.last.sync.time", icon: "", type: .normal, showChevron: false),
    ]),
//    (name: "", items: [
//      .init(key: "icloud.exception.notify", name: "icloud.exception.notify", icon: "", type: .toggle),
//      .init(key: "network.exception.notify", name: "network.exception.notify", icon: "", type: .toggle),
//    ]),
  ]
  
  var body: some View {
    PageView {
      ForEach(Array(zip(sections.indices, sections)), id: \.0) { index, section in
        LazyVStack(spacing: 0) {
          ForEach(section.items) { cell in
            switch cell.type {
            case .toggle:
              switch cell.key {
              case "enable.icloud.sync":
                CellView(cell: cell, isOn: .init(get: {
                  UserDefaults.standard.bool(forKey: "enableiCloudSync")
                }, set: { enableiCloudSync in
                  UserDefaults.standard.set(enableiCloudSync, forKey: "enableiCloudSync")
                }))
              default:
                CellView(cell: cell)
              }
            case .normal:
              switch cell.key {
              case "network":
                CellView(cell: cell, trailingText: "network")
              case "icloud":
                CellView(cell: cell, trailingText: "\(db.iCloudStatus)")
              case "sync.status":
                CellView(cell: cell, trailingText: "\(db.iCloudSyncStatus)")
              case "icloud.last.sync.time":
                CellView(cell: cell, trailingText: "\(db.lastSyncTime.map { Tools.format($0) } ?? "")")
              default:
                Text(cell.key)
              }
            default:
              Text(cell.key)
            }
          }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: ThemeKit.theme.backgroundColor, radius: CGFloat(24), x: 0, y: CGFloat(24))
      }
    }
  }
}

#Preview {
  iCloudSyncView()
    .environment(DBKit())
}
