//
//  SliderView.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/30.
//

import SwiftUI

protocol SliderVeiwProtocol: Identifiable, Hashable {
  var id: String { get }
}
struct SliderVeiw<T: SliderVeiwProtocol, Content: View>: View {
  @Binding var value: String
  @State var items: [T] = []
  @State var axis: Axis.Set
  @State var spacing: CGFloat
  @State var itemSize: CGSize = .zero
  @State var isLoaded: Bool = false
  @ViewBuilder var content: (_ item: T) -> Content
  
  init(
    value: Binding<String>,
    items: [T] = [],
    _ axis: Axis.Set = .horizontal,
    spacing: CGFloat = 12,
    @ViewBuilder content: @escaping (_ item: T) -> Content = { (item: T) in EmptyView() }
  ) {
    self._value = value
    self.items = items
    self.axis = axis
    self.spacing = spacing
    self.content = content
  }
  
  var body: some View {
    GeometryReader {
      let size = $0.size
      let offsetX = (size.width - itemSize.width) / 2
      let offsetY = (size.height - itemSize.height) / 2
      
      let items = Group {
        ForEach(self.items) { item in
          let index = self.items.firstIndex(where: { $0.id == item.id }) ?? 0
          let active = value as? T.ID == item.id
          content(item)
            .background {
              GeometryReader { proxy in
                Color.clear
                  .task(id: proxy.size) {
                    itemSize = proxy.size
                  }
              }
            }
            .shadow(color: .black.opacity(active || index == 0 ? 0.5 : 0), radius: 12, y: 12)
            .scrollTransition(transition: { view, phase in
              view
                .scaleEffect(CGSize(width: phase.isIdentity ? 1.2 : 1, height: phase.isIdentity ? 1.2 : 1))
            })
            .id(item.id)
        }
      }
      
      ScrollView(axis, showsIndicators: false) {
        if axis == .vertical {
          VStack(spacing: spacing) {
            items
          }
          .frame(width: size.width)
          .scrollTargetLayout()
        } else {
          HStack(spacing: spacing) {
            items
          }
          .frame(height: size.height)
          .scrollTargetLayout()
        }
      }
      .scrollTargetBehavior(.viewAligned)
      .scrollPosition(id: Binding(get: {
        isLoaded ? value : nil
      }, set: {
        if let value = $0 {
          self.value = value
        }
      }))
      .safeAreaPadding(axis == Axis.Set.vertical ? .vertical : .horizontal, axis == .vertical ? offsetY : offsetX)
      .onAppear {
        if !isLoaded { isLoaded = true }
      }
    }
  }
}

struct Item: SliderVeiwProtocol {
  var id: String = UUID().uuidString
  var name: String
}

#Preview {
  @Previewable @State var value: String = ""
  VStack {
    //    SliderVeiw(value: $value, items: [Item(name: "1"), Item(name: "2")]) { item in
    //      Text(item.name)
    //        .frame(maxWidth: .infinity)
    //        .border(.black)
    //    }
    //    .border(.black)
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .center, spacing: 0) {
        ForEach(0..<5) { index in
          ZStack {
            Color.blue.opacity(index % 2 == 0 ? 0.8 : 0.6)
              .frame(width: UIScreen.main.bounds.width, height: 300)
            
            Text("Page \(index + 1)")
              .font(.largeTitle)
              .foregroundColor(.white)
          }
          .id(index)
        }
      }
      .frame(height: 300)
      .scrollTargetBehavior(.viewAligned)
      .onAppear {
        UIScrollView.appearance().isPagingEnabled = true
      }
    }
  }
  .frame(maxWidth: .infinity)
}
