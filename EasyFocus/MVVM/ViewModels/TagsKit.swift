//
//  TagsKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

@Observable
final class TagsKit {
  static let shared = TagsKit()
  var tags: [CapLabel] = Bundle.main.decode([CapLabel].self, from: "tags.json")
  var label: CapLabel? = ResourceKit.shared.tags.first
  var modelLabel: FocusLabel? {
    if let label {
      return FocusLabel(
        name: label.name,
        backgroundColor: label.backgroundColor
      )
    }
    return nil
  }
}
