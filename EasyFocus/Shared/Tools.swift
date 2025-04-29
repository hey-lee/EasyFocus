//
//  Tools.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

struct Tools {}

extension Tools {
  static func format(_ date: Date, _ tpl: String = "yyyy-MM-dd HH:mm:ss") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = tpl
    return dateFormatter.string(from: date)
  }
  
  static func toDate(_ dateString: String, _ tpl: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = tpl
    return formatter.date(from: dateString)
  }
  
  static func formatSeconds(_ seconds: Int) -> String {
    guard seconds > 0 else { return "0s" }
    
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    
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
  static func transparentNavBar() {
    UINavigationBar.appearance().shadowImage = UIImage()
    //    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
  }
  
  static func transparentTabBar() {
    let appearance = UITabBarAppearance()
    // transparent background
    appearance.configureWithTransparentBackground()
    // blur effecg
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    // remove border top
    appearance.shadowColor = .clear
    
    // apply
    UITabBar.appearance().standardAppearance = appearance
    
    if #available(iOS 15.0, *) {
      UITabBar.appearance().scrollEdgeAppearance = appearance
    }
  }
  
  static func transparentPageIndicator() {
    UIPageControl.appearance().currentPageIndicatorTintColor = .clear
    UIPageControl.appearance().pageIndicatorTintColor = .clear
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
  
  static func openAppSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
}
