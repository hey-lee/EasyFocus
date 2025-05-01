//
//  ModalKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/1.
//

import SwiftUI

@Observable
final class ModalKit {
  static let shared = ModalKit()
  
  enum ActionType {
    case confirm, cancel
  }
  
  enum Style {}
  
  var show: Bool = false
  var title: String = ""
  var content: String = ""
  var style: Style?
  var onAction: (ActionType) -> () = { _ in }
  
  func showModal(
    title: String,
    content: String,
    style: Style? = nil,
    _ onAction: @escaping (ActionType) -> () = { _ in }
  ) {
    self.title = title
    self.content = content
    self.style = style
    self.onAction = onAction
    show = true
  }

  func modelView(style: Style? = nil) -> some View {
    switch style {
    default:
      defaultModalView(onAction)
    }
  }
  
  func defaultModalView(
    _ onAction: @escaping (ActionType) -> () = { _ in }
  ) -> some View {
    ModalView(
      title: title,
      content: content,
      style: .init(
        content: "",
        cornerRadius: 28,
        foregroundColor: .gray,
        backgroundColor: .white
      ),
//      image: .init(
//        content: "folder.fill.badge.plus",
//        width: 64,
//        height: 64,
//        foregroundColor: .white,
//        backgroundColor: .green
//      ),
      confirm: .init(
        content: "Confirm",cornerRadius: 16,
        foregroundColor: .white,
        backgroundColor: .black,
        action: {
          onAction(.confirm)
        }
      ),
      cancel: .init(
        content: "Cancel",cornerRadius: 16,
        foregroundColor: .white,
        backgroundColor: .red,
        action: {
          onAction(.cancel)
        }
      )
    )
  }
}
