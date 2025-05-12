//
//  ShowKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

final class ShowKit: ObservableObject {
  @Published var tags: Bool = false
  @Published var lego: Bool = false
  @Published var StatsView: Bool = false
  @Published var TimelineView: Bool = false
  @Published var WheelSliderView: Bool = false
  // focus
  @Published var shortBreakSheetView: Bool = false
  @Published var longBreakSheetView: Bool = false
  @Published var sessionsCountSheetView: Bool = false
  // settings
  @Published var FamilyActivityPicker: Bool = false
  //
  @Published var ProView: Bool = false
}
