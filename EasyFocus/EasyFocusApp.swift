//
//  EasyFocusApp.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI
import SwiftData
import CloudKit

@main
struct EasyFocusApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Focus.self,
      FocusLabel.self,
    ])
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false,
      cloudKitDatabase: .private("iCloud.co.banli.apps.easyfocus")
    )
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .environment(DBKit())
    .environment(FocusKit())
    .environment(TagsKit.shared)
    .environmentObject(NavKit())
    .environmentObject(ShowKit())
    .modelContainer(sharedModelContainer)
  }
}
