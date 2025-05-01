//
//  ModalViewModifer.swift
//  EasyFocus
//
//  Created by DBL on 2025/4/29.
//

import SwiftUI

extension View {
  @ViewBuilder
  func modalView<Content: View, Background: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder background: @escaping () -> Background = {
      Rectangle()
        .fill(.primary.opacity(0.35))
    },
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self
      .modifier(
        ModalViewModifer(
          isPresented: isPresented,
          modalContent: content,
          background: background
        )
      )
  }
}

fileprivate struct ModalViewModifer<AlertContent: View, Background: View>: ViewModifier {
  @Binding var isPresented: Bool
  @ViewBuilder var modalContent: AlertContent
  @ViewBuilder var background: Background
  
  @State var showFullScreenCover: Bool = false
  @State var animatedValue: Bool = false
  @State var allowsInteraction: Bool = false
  
  func body(content: Content) -> some View {
    content
      .fullScreenCover(isPresented: $showFullScreenCover) {
        ZStack {
          if animatedValue {
            modalContent
              .allowsHitTesting(allowsInteraction)
              .transition(
                .asymmetric(
                  insertion: .offset(y: 28).combined(with: .opacity),
                  removal: .opacity
                )
              )
              .transition(.blurReplace.combined(with: .push(from: .bottom)))
          }
        }
        .presentationBackground {
          background
            .opacity(animatedValue ? 1 : 0)
        }
        .task {
          try? await Task.sleep(for: .seconds(0.05))
          withAnimation(.easeInOut(duration: 0.3)) {
            animatedValue = true
          }
          
          try? await Task.sleep(for: .seconds(0.3))
          allowsInteraction = true
        }
      }
      .onChange(of: isPresented) { oldValue, newValue in
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        if newValue {
          withTransaction(transaction) {
            showFullScreenCover = true
          }
        } else {
          allowsInteraction = false
          withAnimation(.easeInOut(duration: 0.3)) {
            animatedValue = false
          } completion: {
            withTransaction(transaction) {
              showFullScreenCover = false
            }
          }
        }
      }
  }
}
