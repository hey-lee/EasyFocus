//
//  SettingsView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

struct SettingsView: View {
  @Environment(DBKit.self) var db
  
  var body: some View {
    VStack {
      Text("Settings")
      Text("iCloud: \(db.iCloudStatus)")
      Text("iCloud sync status: \(db.syncStatus)")
      Button("打开系统设置") {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url)
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  SettingsView()
    .environment(DBKit())
}
