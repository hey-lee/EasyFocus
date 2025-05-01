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
  
  static func defaultModalView(
    title: String = "",
    content: String = "",
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
        content: "Save Folder",cornerRadius: 16,
        foregroundColor: .white,
        backgroundColor: .black,
        action: {
          onAction(.confirm)
        }
      ),
      cancel: .init(
        content: "Canecl",cornerRadius: 16,
        foregroundColor: .white,
        backgroundColor: .red,
        action: {
          onAction(.cancel)
        }
      )
    )
  }
}
