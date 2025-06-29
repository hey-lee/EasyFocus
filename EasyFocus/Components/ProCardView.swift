//
//  ProCardView.swift
//  EasyFocus
//
//  Created by DBL on 2025/6/28.
//

import SwiftUI

struct ProCardView: View {
  var body: some View {
    ZStack {
      VStack {
        Spacer()
        HStack {
          Text("Start free trail")
            .foregroundColor(.black.opacity(0.6))
            .font(.title)
            .fontWeight(.heavy)
            .stroke()
          Spacer()
        }
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(
          Image("gradient.6")
            .resizable()
            .scaleEffect(2)
            .blur(radius: 30)
            .ignoresSafeArea()
        )
        .clipShape(.rect(cornerRadius: 24))
      }
    }
    .frame(height: 140)
  }
}

#Preview {
  ProCardView()
}
