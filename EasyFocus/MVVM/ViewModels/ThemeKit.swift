//
//  Theme.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/25.
//

import SwiftUI

struct Theme: Identifiable {
  var id: Int
  var key: String
  var name: String
  var foregroundColor: Color
  var backgroundColor: Color
}

struct ThemeKit {
  @AppStorage("theme") static var themeKey: String = "write"
  static var scheme: ColorScheme?

  static let themes: [Theme] = [
    Theme(
      id: 1,
      key: "white",
      name: "简约白",
      foregroundColor: scheme == .dark ? .slate50 : .slate950,
      backgroundColor: scheme == .dark ? .slate800 : .slate50
    ),
    Theme(
      id: 2,
      key: "yellow",
      name: "Yellow",
      foregroundColor: scheme == .dark ? .yellow50 : .yellow950,
      backgroundColor: scheme == .dark ? .yellow800 : .yellow50
    ),
    Theme(
      id: 3,
      key: "blue",
      name: "Blue",
      foregroundColor: scheme == .dark ? .blue50 : .blue950,
      backgroundColor: scheme == .dark ? .blue800 : .blue50
    ),
    Theme(
      id: 4,
      key: "green",
      name: "Green",
      foregroundColor: scheme == .dark ? .emerald50 : .emerald950,
      backgroundColor: scheme == .dark ? .emerald800 : .emerald50
    ),
    Theme(
      id: 5,
      key: "rose",
      name: "Rose",
      foregroundColor: scheme == .dark ? .rose50 : .rose950,
      backgroundColor: scheme == .dark ? .rose800 : .rose50
    ),
    Theme(
      id: 6,
      key: "purple",
      name: "Purple",
      foregroundColor: scheme == .dark ? .slate50 : .slate950,
      backgroundColor: scheme == .dark ? .slate800 : .slate50
    ),
    Theme(
      id: 7,
      key: "pink",
      name: "Pink",
      foregroundColor: scheme == .dark ? .pink50 : .pink950,
      backgroundColor: scheme == .dark ? .pink800 : .pink50
    ),
  ]
  
  static func setScheme(_ scheme: ColorScheme) {
    ThemeKit.scheme = scheme
  }
  
  static var theme: Theme {
    guard let first = themes.first(where: { $0.key == themeKey }) else {
      return themes[0]
    }
    
    return first
  }
}
