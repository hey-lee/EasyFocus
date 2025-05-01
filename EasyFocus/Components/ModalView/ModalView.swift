//
//  ModalView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI

struct ModalView: View {
  struct Style {
    var content: String
    var width: CGFloat = 0
    var height: CGFloat = 0
    var cornerRadius: CGFloat = 0
    var foregroundColor: Color
    var backgroundColor: Color
    var action: () -> () = {}
  }
  
  enum Result {
    case confirm, cancel
  }
  
  var title: String?
  var content: String?
  var style: Style
  var image: Style?
  var confirm: Style
  var cancel: Style?
  
  var body: some View {
    VStack(spacing: 16) {
      if let title = title {
        Text(title)
          .font(.title3.bold())
      }
      
      if let content {
        Text(content)
          .font(.system(size: 14))
          .multilineTextAlignment(.center)
          .foregroundStyle(style.foregroundColor)
      }
      
      HStack {
        if let cancel {
          ButtonView(cancel)
        }
        ButtonView(confirm)
      }
    }
    .padding()
    .padding(.top, image == nil ? 0 : 32)
    .overlay(alignment: .top) {
      if let image = image {
        Image(systemName: image.content)
          .font(.title)
          .foregroundStyle(image.foregroundColor)
          .frame(width: image.width, height: image.height)
          .background(image.backgroundColor.gradient, in: .circle)
          .background {
            Circle()
              .stroke(.background, lineWidth: 8)
          }
          .offset(y: -image.height / 2)
      }
    }
    .background {
      RoundedRectangle(cornerRadius: style.cornerRadius)
        .fill(.background)
    }
    .frame(maxWidth: 300)
    .compositingGroup()
  }
  
  @ViewBuilder
  func ButtonView(_ button: Style) -> some View {
    Button {
      button.action()
    } label: {
      Text(button.content)
        .fontWeight(.bold)
        .foregroundStyle(button.foregroundColor)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(button.backgroundColor.gradient, in: .rect(cornerRadius: button.cornerRadius))
    }
  }
}

struct PreviewView: View {
  @State var show: Bool = false
  var body: some View {
    VStack {
      Button("alert") {
        ModalKit.shared.showModal(title: "title", content: "content") { action in
          switch action {
          case .confirm:
            print("confirm")
          case .cancel:
            ModalKit.shared.show = false
          }
        }
      }
      .modalView(isPresented: .init(get: {
        ModalKit.shared.show
      }, set: { show in
        ModalKit.shared.show = show
      })) {
        ModalKit.shared.modelView()
      }
    }
    .onChange(of: ModalKit.shared.show, { oldValue, newValue in
      print(ModalKit.shared.show)
    })
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  PreviewView()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.slate50)
}
