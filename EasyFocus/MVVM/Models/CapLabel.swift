//
//  CapLabel.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct CapLabel: Decodable, Identifiable, Hashable, Equatable {
  var id: String = UUID().uuidString
  var name: String
  var icon: String
  var backgroundColor: String = ""
}
