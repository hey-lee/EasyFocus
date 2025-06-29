//
//  CellView.swift
//  EasyFocus
//
//  Created by 大板栗 on 2025/4/25.
//

import SwiftUI

extension CellView {
  enum CellType {
    case normal
    case toggle
    case sheet
  }
  
  struct Cell: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var key: String
    var name: String
    var icon: String = ""
    var colors: [Color] = []
    var foregroundColor: Color = .white
    var description: String = ""
    var trailingText: String = ""
    var type: CellType?
    var showChevron: Bool = true
  }
}

struct CellView: View {
  @State var cell: CellView.Cell
  var isOn: Binding<Bool>? = nil
  var trailingText: String = ""
  
  init(
    cell: CellView.Cell,
    isOn: Binding<Bool>? = nil,
    trailingText: String = ""
  ) {
    self.cell = cell
    self.isOn = isOn
    self.trailingText = trailingText
  }
  
  var body: some View {
    GeometryReader {
      let size = $0.size
      HStack {
        if !cell.icon.isEmpty {
          Symbol(cell.icon, colors: cell.colors, foregroundColor: cell.foregroundColor)
            .stroke(width: 2, shadow: .init(x: 1, y: 2, radius: 1, color: .black.opacity(0.2)))
        }
        
        VStack(alignment: .leading, spacing: 0) {
          Text(LocalizedStringKey(cell.name))
            .font(.subheadline)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
          if !cell.description.isEmpty {
            Text(LocalizedStringKey(cell.description))
              .font(.caption)
              .foregroundColor(.slate600)
          }
        }
        Spacer()
        Text(trailingText.isEmpty ? cell.trailingText : trailingText)
          .font(.footnote)
          .foregroundColor(.slate600)

        Group {
          if let isOn {
            Toggle("", isOn: isOn)
          } else {
            if cell.showChevron {
              Image(systemName: "chevron.compact.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 12)
                .foregroundColor(.slate400)
            }
          }
        }
      }
      .padding(.leading, 8)
      .padding(.trailing, 16)
      .frame(height: size.height)
      .contentShape(Rectangle())
      .clipShape(.rect())
    }
    .frame(height: cell.icon.isEmpty ? 52 : 64)
  }
}

#Preview {
  PageView {
    VStack {
      CellView(cell: .init(
        key: "reminder",
        name: "Reminder",
        icon: "sf.bell.fill",
        foregroundColor: Color.slate600,
        description: "Enable reminder",
        type: .toggle
      ), isOn: .constant(true))
      CellView(cell: .init(
        key: "voice.accent",
        name: "Voice Accent",
        icon: "sf.headphones",
        foregroundColor: Color.slate600,
        description: "Change the voice accent"
      ))
    }
    .glassmorphic(cornerRadius: 24)
  }
}
