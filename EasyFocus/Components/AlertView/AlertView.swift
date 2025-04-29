//
//  AlertView.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI

struct ModalView: View {
  struct Config {
    var tint: Color
    var content: String
    var foreground: Color
    var action: (String) -> () = { _ in }
  }
  
  var title: String
  var content: String?
  var image: Config
  var button1: Config
  var button2: Config?
  var addsTextField: Bool = false
  var textFieldHint: String = ""
  var backgroundColor: Color
  
  @State var text: String = ""
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: image.content)
        .font(.title)
        .foregroundStyle(image.foreground)
        .frame(width: 64, height: 64)
        .background(image.tint.gradient, in: .circle)
        .background {
          Circle()
            .stroke(.background, lineWidth: 8)
        }
      
      Text(title)
        .font(.title3.bold())
      
      if let content {
        Text(content)
          .font(.system(size: 14))
          .multilineTextAlignment(.center)
          .lineLimit(2)
          .foregroundStyle(.gray)
      }
      
      if addsTextField {
        TextField(textFieldHint, text: $text)
          .padding(.horizontal)
          .padding(.vertical, 12)
          .background {
            RoundedRectangle(cornerRadius: 12)
              .fill(.gray.opacity(0.1))
          }
          .padding(.bottom, 4)
      }
      
      ButtonView(button1)
      
      if let button2 {
        ButtonView(button2)
      }
    }
    .padding([.horizontal, .bottom])
    .background {
      RoundedRectangle(cornerRadius: 16)
        .fill(.background)
        .padding(.top, 32)
    }
    .frame(maxWidth: 300)
    .compositingGroup()
  }
  
  @ViewBuilder
  func ButtonView(_ button: Config) -> some View {
    Button {
      button.action(addsTextField ? text : "")
    } label: {
      Text(button.content)
        .fontWeight(.bold)
        .foregroundStyle(button.foreground)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(button.tint.gradient, in: .rect(cornerRadius: 12))
    }
  }
}

struct PreviewView: View {
  @State var show: Bool = false
  var body: some View {
    VStack {
      Button("alert") {
        show = true
      }
      .alertView(isPresented: $show, content: {
        ModalView(
          title: "Folder Name",
          content: "Enter a file Name",
          image: .init(
            tint: Color.green,
            content: "folder.fill.badge.plus",
            foreground: .white
          ),
          button1: .init(
            tint: .black,
            content: "Save Folder",
            foreground: .white,
            action: { folder in
              print(folder)
            }
          ),
          button2: .init(
            tint: .red,
            content: "Canecl",
            foreground: .white,
            action: { _ in
              show = false
            }
          ),
          addsTextField: true,
          textFieldHint: "Personal Documents",
          backgroundColor: .white,
          text: "sdfsdfsdf"
        )
      })
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  PreviewView()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.slate50)
}
