//
//  Tools.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct Tools {}

extension Tools {
  static func formatSeconds(_ seconds: Int) -> String {
    guard seconds > 0 else { return "0s" }

    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60
    
    if hours > 0 {
      return "\(hours)h\(minutes)m"
    } else if minutes > 0 {
      return "\(minutes)m"
    } else {
      return "\(seconds)s"
    }
  }
}

extension Tools {
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
