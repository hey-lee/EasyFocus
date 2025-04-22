//
//  Color++.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/22.
//

import SwiftUI

extension String {
  func droppingLeadingPoundSign() -> String {
    if starts(with: "#") {
      return String(dropFirst())
    }
    return self
  }
}

extension Color {
  init(_ hex: Int, _ alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
  init(hex: String, opacity: Double = 1) {
    let hex = hex.starts(with: "#") ? String(hex.dropFirst()) : hex
    var rgbValue: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&rgbValue)
    
    self.init(
      .sRGB,
      red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: Double(rgbValue & 0x0000FF) / 255.0,
      opacity: opacity
    )
  }
  // Slate
    public static let slate50 = Color(hex: "#f8fafc")
    public static let slate50s: String = "#f8fafc"
    public static let slate100 = Color(hex: "#f1f5f9")
    public static let slate100s: String = "#f1f5f9"
    public static let slate200 = Color(hex: "#e2e8f0")
    public static let slate200s: String = "#e2e8f0"
    public static let slate300 = Color(hex: "#cbd5e1")
    public static let slate300s: String = "#cbd5e1"
    public static let slate400 = Color(hex: "#94a3b8")
    public static let slate400s: String = "#94a3b8"
    public static let slate500 = Color(hex: "#64748b")
    public static let slate500s: String = "#64748b"
    public static let slate600 = Color(hex: "#475569")
    public static let slate600s: String = "#475569"
    public static let slate700 = Color(hex: "#334155")
    public static let slate700s: String = "#334155"
    public static let slate800 = Color(hex: "#1e293b")
    public static let slate800s: String = "#1e293b"
    public static let slate900 = Color(hex: "#0f172a")
    public static let slate900s: String = "#0f172a"
    public static let slate950 = Color(hex: "#020617")
    public static let slate950s: String = "#020617"
    // Gray
    public static let gray50 = Color(hex: "#f9fafb")
    public static let gray50s: String = "#f9fafb"
    public static let gray100 = Color(hex: "#f3f4f6")
    public static let gray100s: String = "#f3f4f6"
    public static let gray200 = Color(hex: "#e5e7eb")
    public static let gray200s: String = "#e5e7eb"
    public static let gray300 = Color(hex: "#d1d5db")
    public static let gray300s: String = "#d1d5db"
    public static let gray400 = Color(hex: "#9ca3af")
    public static let gray400s: String = "#9ca3af"
    public static let gray500 = Color(hex: "#6b7280")
    public static let gray500s: String = "#6b7280"
    public static let gray600 = Color(hex: "#4b5563")
    public static let gray600s: String = "#4b5563"
    public static let gray700 = Color(hex: "#374151")
    public static let gray700s: String = "#374151"
    public static let gray800 = Color(hex: "#1f2937")
    public static let gray800s: String = "#1f2937"
    public static let gray900 = Color(hex: "#111827")
    public static let gray900s: String = "#111827"
    public static let gray950 = Color(hex: "#030712")
    public static let gray950s: String = "#030712"
    // Zinc
    public static let zinc50 = Color(hex: "#fafafa")
    public static let zinc50s: String = "#fafafa"
    public static let zinc100 = Color(hex: "#f4f4f5")
    public static let zinc100s: String = "#f4f4f5"
    public static let zinc200 = Color(hex: "#e4e4e7")
    public static let zinc200s: String = "#e4e4e7"
    public static let zinc300 = Color(hex: "#d4d4d8")
    public static let zinc300s: String = "#d4d4d8"
    public static let zinc400 = Color(hex: "#a1a1aa")
    public static let zinc400s: String = "#a1a1aa"
    public static let zinc500 = Color(hex: "#71717a")
    public static let zinc500s: String = "#71717a"
    public static let zinc600 = Color(hex: "#52525b")
    public static let zinc600s: String = "#52525b"
    public static let zinc700 = Color(hex: "#3f3f46")
    public static let zinc700s: String = "#3f3f46"
    public static let zinc800 = Color(hex: "#27272a")
    public static let zinc800s: String = "#27272a"
    public static let zinc900 = Color(hex: "#18181b")
    public static let zinc900s: String = "#18181b"
    public static let zinc950 = Color(hex: "#09090b")
    public static let zinc950s: String = "#09090b"
    // Neutral
    public static let neutral50 = Color(hex: "#fafafa")
    public static let neutral50s: String = "#fafafa"
    public static let neutral100 = Color(hex: "#f5f5f5")
    public static let neutral100s: String = "#f5f5f5"
    public static let neutral200 = Color(hex: "#e5e5e5")
    public static let neutral200s: String = "#e5e5e5"
    public static let neutral300 = Color(hex: "#d4d4d4")
    public static let neutral300s: String = "#d4d4d4"
    public static let neutral400 = Color(hex: "#a3a3a3")
    public static let neutral400s: String = "#a3a3a3"
    public static let neutral500 = Color(hex: "#737373")
    public static let neutral500s: String = "#737373"
    public static let neutral600 = Color(hex: "#525252")
    public static let neutral600s: String = "#525252"
    public static let neutral700 = Color(hex: "#404040")
    public static let neutral700s: String = "#404040"
    public static let neutral800 = Color(hex: "#262626")
    public static let neutral800s: String = "#262626"
    public static let neutral900 = Color(hex: "#171717")
    public static let neutral900s: String = "#171717"
    public static let neutral950 = Color(hex: "#0a0a0a")
    public static let neutral950s: String = "#0a0a0a"
    // Stone
    public static let stone50 = Color(hex: "#fafaf9")
    public static let stone50s: String = "#fafaf9"
    public static let stone100 = Color(hex: "#f5f5f4")
    public static let stone100s: String = "#f5f5f4"
    public static let stone200 = Color(hex: "#e7e5e4")
    public static let stone200s: String = "#e7e5e4"
    public static let stone300 = Color(hex: "#d6d3d1")
    public static let stone300s: String = "#d6d3d1"
    public static let stone400 = Color(hex: "#a8a29e")
    public static let stone400s: String = "#a8a29e"
    public static let stone500 = Color(hex: "#78716c")
    public static let stone500s: String = "#78716c"
    public static let stone600 = Color(hex: "#57534e")
    public static let stone600s: String = "#57534e"
    public static let stone700 = Color(hex: "#44403c")
    public static let stone700s: String = "#44403c"
    public static let stone800 = Color(hex: "#292524")
    public static let stone800s: String = "#292524"
    public static let stone900 = Color(hex: "#1c1917")
    public static let stone900s: String = "#1c1917"
    public static let stone950 = Color(hex: "#0c0a09")
    public static let stone950s: String = "#0c0a09"
    // Red
    public static let red50 = Color(hex: "#fef2f2")
    public static let red50s: String = "#fef2f2"
    public static let red100 = Color(hex: "#fee2e2")
    public static let red100s: String = "#fee2e2"
    public static let red200 = Color(hex: "#fecaca")
    public static let red200s: String = "#fecaca"
    public static let red300 = Color(hex: "#fca5a5")
    public static let red300s: String = "#fca5a5"
    public static let red400 = Color(hex: "#f87171")
    public static let red400s: String = "#f87171"
    public static let red500 = Color(hex: "#ef4444")
    public static let red500s: String = "#ef4444"
    public static let red600 = Color(hex: "#dc2626")
    public static let red600s: String = "#dc2626"
    public static let red700 = Color(hex: "#b91c1c")
    public static let red700s: String = "#b91c1c"
    public static let red800 = Color(hex: "#991b1b")
    public static let red800s: String = "#991b1b"
    public static let red900 = Color(hex: "#7f1d1d")
    public static let red900s: String = "#7f1d1d"
    public static let red950 = Color(hex: "#450a0a")
    public static let red950s: String = "#450a0a"
    // Orange
    public static let orange50 = Color(hex: "#fff7ed")
    public static let orange50s: String = "#fff7ed"
    public static let orange100 = Color(hex: "#ffedd5")
    public static let orange100s: String = "#ffedd5"
    public static let orange200 = Color(hex: "#fed7aa")
    public static let orange200s: String = "#fed7aa"
    public static let orange300 = Color(hex: "#fdba74")
    public static let orange300s: String = "#fdba74"
    public static let orange400 = Color(hex: "#fb923c")
    public static let orange400s: String = "#fb923c"
    public static let orange500 = Color(hex: "#f97316")
    public static let orange500s: String = "#f97316"
    public static let orange600 = Color(hex: "#ea580c")
    public static let orange600s: String = "#ea580c"
    public static let orange700 = Color(hex: "#c2410c")
    public static let orange700s: String = "#c2410c"
    public static let orange800 = Color(hex: "#9a3412")
    public static let orange800s: String = "#9a3412"
    public static let orange900 = Color(hex: "#7c2d12")
    public static let orange900s: String = "#7c2d12"
    public static let orange950 = Color(hex: "#431407")
    public static let orange950s: String = "#431407"
    // Amber
    public static let amber50 = Color(hex: "#fffbeb")
    public static let amber50s: String = "#fffbeb"
    public static let amber100 = Color(hex: "#fef3c7")
    public static let amber100s: String = "#fef3c7"
    public static let amber200 = Color(hex: "#fde68a")
    public static let amber200s: String = "#fde68a"
    public static let amber300 = Color(hex: "#fcd34d")
    public static let amber300s: String = "#fcd34d"
    public static let amber400 = Color(hex: "#fbbf24")
    public static let amber400s: String = "#fbbf24"
    public static let amber500 = Color(hex: "#f59e0b")
    public static let amber500s: String = "#f59e0b"
    public static let amber600 = Color(hex: "#d97706")
    public static let amber600s: String = "#d97706"
    public static let amber700 = Color(hex: "#b45309")
    public static let amber700s: String = "#b45309"
    public static let amber800 = Color(hex: "#92400e")
    public static let amber800s: String = "#92400e"
    public static let amber900 = Color(hex: "#78350f")
    public static let amber900s: String = "#78350f"
    public static let amber950 = Color(hex: "#451a03")
    public static let amber950s: String = "#451a03"
    // Yellow
    public static let yellow50 = Color(hex: "#fefce8")
    public static let yellow50s: String = "#fefce8"
    public static let yellow100 = Color(hex: "#fef9c3")
    public static let yellow100s: String = "#fef9c3"
    public static let yellow200 = Color(hex: "#fef08a")
    public static let yellow200s: String = "#fef08a"
    public static let yellow300 = Color(hex: "#fde047")
    public static let yellow300s: String = "#fde047"
    public static let yellow400 = Color(hex: "#facc15")
    public static let yellow400s: String = "#facc15"
    public static let yellow500 = Color(hex: "#eab308")
    public static let yellow500s: String = "#eab308"
    public static let yellow600 = Color(hex: "#ca8a04")
    public static let yellow600s: String = "#ca8a04"
    public static let yellow700 = Color(hex: "#a16207")
    public static let yellow700s: String = "#a16207"
    public static let yellow800 = Color(hex: "#854d0e")
    public static let yellow800s: String = "#854d0e"
    public static let yellow900 = Color(hex: "#713f12")
    public static let yellow900s: String = "#713f12"
    public static let yellow950 = Color(hex: "#422006")
    public static let yellow950s: String = "#422006"
    // Lime
    public static let lime50 = Color(hex: "#f7fee7")
    public static let lime50s: String = "#f7fee7"
    public static let lime100 = Color(hex: "#ecfccb")
    public static let lime100s: String = "#ecfccb"
    public static let lime200 = Color(hex: "#d9f99d")
    public static let lime200s: String = "#d9f99d"
    public static let lime300 = Color(hex: "#bef264")
    public static let lime300s: String = "#bef264"
    public static let lime400 = Color(hex: "#a3e635")
    public static let lime400s: String = "#a3e635"
    public static let lime500 = Color(hex: "#84cc16")
    public static let lime500s: String = "#84cc16"
    public static let lime600 = Color(hex: "#65a30d")
    public static let lime600s: String = "#65a30d"
    public static let lime700 = Color(hex: "#4d7c0f")
    public static let lime700s: String = "#4d7c0f"
    public static let lime800 = Color(hex: "#3f6212")
    public static let lime800s: String = "#3f6212"
    public static let lime900 = Color(hex: "#365314")
    public static let lime900s: String = "#365314"
    public static let lime950 = Color(hex: "#1a2e05")
    public static let lime950s: String = "#1a2e05"
    // Green
    public static let green50 = Color(hex: "#f0fdf4")
    public static let green50s: String = "#f0fdf4"
    public static let green100 = Color(hex: "#dcfce7")
    public static let green100s: String = "#dcfce7"
    public static let green200 = Color(hex: "#bbf7d0")
    public static let green200s: String = "#bbf7d0"
    public static let green300 = Color(hex: "#86efac")
    public static let green300s: String = "#86efac"
    public static let green400 = Color(hex: "#4ade80")
    public static let green400s: String = "#4ade80"
    public static let green500 = Color(hex: "#22c55e")
    public static let green500s: String = "#22c55e"
    public static let green600 = Color(hex: "#16a34a")
    public static let green600s: String = "#16a34a"
    public static let green700 = Color(hex: "#15803d")
    public static let green700s: String = "#15803d"
    public static let green800 = Color(hex: "#166534")
    public static let green800s: String = "#166534"
    public static let green900 = Color(hex: "#14532d")
    public static let green900s: String = "#14532d"
    public static let green950 = Color(hex: "#052e16")
    public static let green950s: String = "#052e16"
    // Emerald
    public static let emerald50 = Color(hex: "#ecfdf5")
    public static let emerald50s: String = "#ecfdf5"
    public static let emerald100 = Color(hex: "#d1fae5")
    public static let emerald100s: String = "#d1fae5"
    public static let emerald200 = Color(hex: "#a7f3d0")
    public static let emerald200s: String = "#a7f3d0"
    public static let emerald300 = Color(hex: "#6ee7b7")
    public static let emerald300s: String = "#6ee7b7"
    public static let emerald400 = Color(hex: "#34d399")
    public static let emerald400s: String = "#34d399"
    public static let emerald500 = Color(hex: "#10b981")
    public static let emerald500s: String = "#10b981"
    public static let emerald600 = Color(hex: "#059669")
    public static let emerald600s: String = "#059669"
    public static let emerald700 = Color(hex: "#047857")
    public static let emerald700s: String = "#047857"
    public static let emerald800 = Color(hex: "#065f46")
    public static let emerald800s: String = "#065f46"
    public static let emerald900 = Color(hex: "#064e3b")
    public static let emerald900s: String = "#064e3b"
    public static let emerald950 = Color(hex: "#022c22")
    public static let emerald950s: String = "#022c22"
    // Teal
    public static let teal50 = Color(hex: "#f0fdfa")
    public static let teal50s: String = "#f0fdfa"
    public static let teal100 = Color(hex: "#ccfbf1")
    public static let teal100s: String = "#ccfbf1"
    public static let teal200 = Color(hex: "#99f6e4")
    public static let teal200s: String = "#99f6e4"
    public static let teal300 = Color(hex: "#5eead4")
    public static let teal300s: String = "#5eead4"
    public static let teal400 = Color(hex: "#2dd4bf")
    public static let teal400s: String = "#2dd4bf"
    public static let teal500 = Color(hex: "#14b8a6")
    public static let teal500s: String = "#14b8a6"
    public static let teal600 = Color(hex: "#0d9488")
    public static let teal600s: String = "#0d9488"
    public static let teal700 = Color(hex: "#0f766e")
    public static let teal700s: String = "#0f766e"
    public static let teal800 = Color(hex: "#115e59")
    public static let teal800s: String = "#115e59"
    public static let teal900 = Color(hex: "#134e4a")
    public static let teal900s: String = "#134e4a"
    public static let teal950 = Color(hex: "#042f2e")
    public static let teal950s: String = "#042f2e"
    // Cyan
    public static let cyan50 = Color(hex: "#ecfeff")
    public static let cyan50s: String = "#ecfeff"
    public static let cyan100 = Color(hex: "#cffafe")
    public static let cyan100s: String = "#cffafe"
    public static let cyan200 = Color(hex: "#a5f3fc")
    public static let cyan200s: String = "#a5f3fc"
    public static let cyan300 = Color(hex: "#67e8f9")
    public static let cyan300s: String = "#67e8f9"
    public static let cyan400 = Color(hex: "#22d3ee")
    public static let cyan400s: String = "#22d3ee"
    public static let cyan500 = Color(hex: "#06b6d4")
    public static let cyan500s: String = "#06b6d4"
    public static let cyan600 = Color(hex: "#0891b2")
    public static let cyan600s: String = "#0891b2"
    public static let cyan700 = Color(hex: "#0e7490")
    public static let cyan700s: String = "#0e7490"
    public static let cyan800 = Color(hex: "#155e75")
    public static let cyan800s: String = "#155e75"
    public static let cyan900 = Color(hex: "#164e63")
    public static let cyan900s: String = "#164e63"
    public static let cyan950 = Color(hex: "#083344")
    public static let cyan950s: String = "#083344"
    // Sky
    public static let sky50 = Color(hex: "#f0f9ff")
    public static let sky50s: String = "#f0f9ff"
    public static let sky100 = Color(hex: "#e0f2fe")
    public static let sky100s: String = "#e0f2fe"
    public static let sky200 = Color(hex: "#bae6fd")
    public static let sky200s: String = "#bae6fd"
    public static let sky300 = Color(hex: "#7dd3fc")
    public static let sky300s: String = "#7dd3fc"
    public static let sky400 = Color(hex: "#38bdf8")
    public static let sky400s: String = "#38bdf8"
    public static let sky500 = Color(hex: "#0ea5e9")
    public static let sky500s: String = "#0ea5e9"
    public static let sky600 = Color(hex: "#0284c7")
    public static let sky600s: String = "#0284c7"
    public static let sky700 = Color(hex: "#0369a1")
    public static let sky700s: String = "#0369a1"
    public static let sky800 = Color(hex: "#075985")
    public static let sky800s: String = "#075985"
    public static let sky900 = Color(hex: "#0c4a6e")
    public static let sky900s: String = "#0c4a6e"
    public static let sky950 = Color(hex: "#082f49")
    public static let sky950s: String = "#082f49"
    // Blue
    public static let blue50 = Color(hex: "#eff6ff")
    public static let blue50s: String = "#eff6ff"
    public static let blue100 = Color(hex: "#dbeafe")
    public static let blue100s: String = "#dbeafe"
    public static let blue200 = Color(hex: "#bfdbfe")
    public static let blue200s: String = "#bfdbfe"
    public static let blue300 = Color(hex: "#93c5fd")
    public static let blue300s: String = "#93c5fd"
    public static let blue400 = Color(hex: "#60a5fa")
    public static let blue400s: String = "#60a5fa"
    public static let blue500 = Color(hex: "#3b82f6")
    public static let blue500s: String = "#3b82f6"
    public static let blue600 = Color(hex: "#2563eb")
    public static let blue600s: String = "#2563eb"
    public static let blue700 = Color(hex: "#1d4ed8")
    public static let blue700s: String = "#1d4ed8"
    public static let blue800 = Color(hex: "#1e40af")
    public static let blue800s: String = "#1e40af"
    public static let blue900 = Color(hex: "#1e3a8a")
    public static let blue900s: String = "#1e3a8a"
    public static let blue950 = Color(hex: "#172554")
    public static let blue950s: String = "#172554"
    // Indigo
    public static let indigo50 = Color(hex: "#eef2ff")
    public static let indigo50s: String = "#eef2ff"
    public static let indigo100 = Color(hex: "#e0e7ff")
    public static let indigo100s: String = "#e0e7ff"
    public static let indigo200 = Color(hex: "#c7d2fe")
    public static let indigo200s: String = "#c7d2fe"
    public static let indigo300 = Color(hex: "#a5b4fc")
    public static let indigo300s: String = "#a5b4fc"
    public static let indigo400 = Color(hex: "#818cf8")
    public static let indigo400s: String = "#818cf8"
    public static let indigo500 = Color(hex: "#6366f1")
    public static let indigo500s: String = "#6366f1"
    public static let indigo600 = Color(hex: "#4f46e5")
    public static let indigo600s: String = "#4f46e5"
    public static let indigo700 = Color(hex: "#4338ca")
    public static let indigo700s: String = "#4338ca"
    public static let indigo800 = Color(hex: "#3730a3")
    public static let indigo800s: String = "#3730a3"
    public static let indigo900 = Color(hex: "#312e81")
    public static let indigo900s: String = "#312e81"
    public static let indigo950 = Color(hex: "#1e1b4b")
    public static let indigo950s: String = "#1e1b4b"
    // Violet
    public static let violet50 = Color(hex: "#f5f3ff")
    public static let violet50s: String = "#f5f3ff"
    public static let violet100 = Color(hex: "#ede9fe")
    public static let violet100s: String = "#ede9fe"
    public static let violet200 = Color(hex: "#ddd6fe")
    public static let violet200s: String = "#ddd6fe"
    public static let violet300 = Color(hex: "#c4b5fd")
    public static let violet300s: String = "#c4b5fd"
    public static let violet400 = Color(hex: "#a78bfa")
    public static let violet400s: String = "#a78bfa"
    public static let violet500 = Color(hex: "#8b5cf6")
    public static let violet500s: String = "#8b5cf6"
    public static let violet600 = Color(hex: "#7c3aed")
    public static let violet600s: String = "#7c3aed"
    public static let violet700 = Color(hex: "#6d28d9")
    public static let violet700s: String = "#6d28d9"
    public static let violet800 = Color(hex: "#5b21b6")
    public static let violet800s: String = "#5b21b6"
    public static let violet900 = Color(hex: "#4c1d95")
    public static let violet900s: String = "#4c1d95"
    public static let violet950 = Color(hex: "#2e1065")
    public static let violet950s: String = "#2e1065"
    // Purple
    public static let purple50 = Color(hex: "#faf5ff")
    public static let purple50s: String = "#faf5ff"
    public static let purple100 = Color(hex: "#f3e8ff")
    public static let purple100s: String = "#f3e8ff"
    public static let purple200 = Color(hex: "#e9d5ff")
    public static let purple200s: String = "#e9d5ff"
    public static let purple300 = Color(hex: "#d8b4fe")
    public static let purple300s: String = "#d8b4fe"
    public static let purple400 = Color(hex: "#c084fc")
    public static let purple400s: String = "#c084fc"
    public static let purple500 = Color(hex: "#a855f7")
    public static let purple500s: String = "#a855f7"
    public static let purple600 = Color(hex: "#9333ea")
    public static let purple600s: String = "#9333ea"
    public static let purple700 = Color(hex: "#7e22ce")
    public static let purple700s: String = "#7e22ce"
    public static let purple800 = Color(hex: "#6b21a8")
    public static let purple800s: String = "#6b21a8"
    public static let purple900 = Color(hex: "#581c87")
    public static let purple900s: String = "#581c87"
    public static let purple950 = Color(hex: "#3b0764")
    public static let purple950s: String = "#3b0764"
    // Fuchsia
    public static let fuchsia50 = Color(hex: "#fdf4ff")
    public static let fuchsia50s: String = "#fdf4ff"
    public static let fuchsia100 = Color(hex: "#fae8ff")
    public static let fuchsia100s: String = "#fae8ff"
    public static let fuchsia200 = Color(hex: "#f5d0fe")
    public static let fuchsia200s: String = "#f5d0fe"
    public static let fuchsia300 = Color(hex: "#f0abfc")
    public static let fuchsia300s: String = "#f0abfc"
    public static let fuchsia400 = Color(hex: "#e879f9")
    public static let fuchsia400s: String = "#e879f9"
    public static let fuchsia500 = Color(hex: "#d946ef")
    public static let fuchsia500s: String = "#d946ef"
    public static let fuchsia600 = Color(hex: "#c026d3")
    public static let fuchsia600s: String = "#c026d3"
    public static let fuchsia700 = Color(hex: "#a21caf")
    public static let fuchsia700s: String = "#a21caf"
    public static let fuchsia800 = Color(hex: "#86198f")
    public static let fuchsia800s: String = "#86198f"
    public static let fuchsia900 = Color(hex: "#701a75")
    public static let fuchsia900s: String = "#701a75"
    public static let fuchsia950 = Color(hex: "#4a044e")
    public static let fuchsia950s: String = "#4a044e"
    // Pink
    public static let pink50 = Color(hex: "#fdf2f8")
    public static let pink50s: String = "#fdf2f8"
    public static let pink100 = Color(hex: "#fce7f3")
    public static let pink100s: String = "#fce7f3"
    public static let pink200 = Color(hex: "#fbcfe8")
    public static let pink200s: String = "#fbcfe8"
    public static let pink300 = Color(hex: "#f9a8d4")
    public static let pink300s: String = "#f9a8d4"
    public static let pink400 = Color(hex: "#f472b6")
    public static let pink400s: String = "#f472b6"
    public static let pink500 = Color(hex: "#ec4899")
    public static let pink500s: String = "#ec4899"
    public static let pink600 = Color(hex: "#db2777")
    public static let pink600s: String = "#db2777"
    public static let pink700 = Color(hex: "#be185d")
    public static let pink700s: String = "#be185d"
    public static let pink800 = Color(hex: "#9d174d")
    public static let pink800s: String = "#9d174d"
    public static let pink900 = Color(hex: "#831843")
    public static let pink900s: String = "#831843"
    public static let pink950 = Color(hex: "#500724")
    public static let pink950s: String = "#500724"
    // Rose
    public static let rose50 = Color(hex: "#fff1f2")
    public static let rose50s: String = "#fff1f2"
    public static let rose100 = Color(hex: "#ffe4e6")
    public static let rose100s: String = "#ffe4e6"
    public static let rose200 = Color(hex: "#fecdd3")
    public static let rose200s: String = "#fecdd3"
    public static let rose300 = Color(hex: "#fda4af")
    public static let rose300s: String = "#fda4af"
    public static let rose400 = Color(hex: "#fb7185")
    public static let rose400s: String = "#fb7185"
    public static let rose500 = Color(hex: "#f43f5e")
    public static let rose500s: String = "#f43f5e"
    public static let rose600 = Color(hex: "#e11d48")
    public static let rose600s: String = "#e11d48"
    public static let rose700 = Color(hex: "#be123c")
    public static let rose700s: String = "#be123c"
    public static let rose800 = Color(hex: "#9f1239")
    public static let rose800s: String = "#9f1239"
    public static let rose900 = Color(hex: "#881337")
    public static let rose900s: String = "#881337"
    public static let rose950s: String = "#4c0519"
    public static let rose950 = Color(hex: "#4c0519")
}
