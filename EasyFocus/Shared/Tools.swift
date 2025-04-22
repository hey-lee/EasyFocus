//
//  Tools.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct Tools {
  @AppStorage("enableHaptic") static var enableHaptic: Bool = true
  public static func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
    if enableHaptic {
      let generator = UIImpactFeedbackGenerator(style: style)
      generator.impactOccurred()
    }
  }
  
  public static func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    if enableHaptic {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(type)
    }
  }
}
