//
//  ResourceKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

@Observable
final class ResourceKit {
  static let shared = ResourceKit()
  var tags: [CapLabel] = Bundle.main.decode([CapLabel].self, from: "tags.json")
}
