//
//  NavKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/24.
//

import Foundation

final class NavKit: ObservableObject {
  enum NavType {
    case settings, focus, stats
  }
  @Published var activeNav: NavType = .focus
}
