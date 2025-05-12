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
  @AppStorage("mode") var isDark = false
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Focus.self,
      FocusLabel.self,
    ])
    let modelConfiguration: ModelConfiguration
    
    if UserDefaults.standard.bool(forKey: "enableiCloudSync") {
      modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .private("iCloud.co.banli.apps.easyfocus")
      )
    } else {
      modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
      )
    }
    
    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .modalView(isPresented: .init(get: {
          ModalKit.shared.show
        }, set: { show in
          ModalKit.shared.show = show
        })) {
          ModalKit.shared.modelView()
        }
        .preferredColorScheme(isDark ? .dark : .light)
        .task(id: scenePhase) {
          if scenePhase == .active {
            await Store.shared.fetchTransactions()
          }
        }
    }
    .environment(DBKit())
    .environment(FocusKit())
    .environment(TagsKit.shared)
    .environment(ModalKit.shared)
    .environment(StoreService.shared)
    .environment(FocusService())
    .environmentObject(NavKit())
    .environmentObject(Stackit())
    .environmentObject(ShowKit())
    .modelContainer(sharedModelContainer)
  }
}
