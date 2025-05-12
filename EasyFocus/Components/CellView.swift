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
          Symbol(cell.icon, colors: cell.colors, foregroundColor: Color.white)
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
      .padding(.horizontal, 10)
      .frame(height: size.height)
      .background(.white)
      .contentShape(Rectangle())
      .clipShape(.rect())
    }
    .frame(height: cell.icon.isEmpty ? 52 : 64)
  }
}

#Preview {
  VStack {
    CellView(cell: CellView.Cell(key: "cell.view", name: "CellView", icon: "", colors: [Color.blue400], description: "description"))
  }
  .padding(.horizontal)
  .frame(maxWidth: .infinity, maxHeight: .infinity)
  .background(Color.sky50)
}
