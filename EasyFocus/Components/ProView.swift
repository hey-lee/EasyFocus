//
//  ProView.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/12.
//

import SwiftUI

struct ProLabel: View {
  var body: some View {
    Text("PRO")
//      .font(.custom(Tools.Font_CodeNext, size: 14))
      .foregroundStyle(Color.slate800)
      .padding(6)
      .background(
        Color.yellow400
      )
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}

struct ProView: View {
  var body: some View {
    PageView {
      //
    }
  }
}

struct ProductsView: View {
  @Environment(\.dismiss) var dismiss
  @State var index: Int = 1
  
  init() {
    Tools.transparentNavBar()
  }
  
  var body: some View {
    NavigationStack {
      GeometryReader {
        let size = $0.size
        ZStack {
          ScrollView {
            VStack {
              TabView {
                Group {
                  VStack {
                    Text("1")
                  }
                  VStack {
                    Text("2")
                  }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .frame(height: 240)
              .tabViewStyle(.page(indexDisplayMode: .always))
              
              BrandView()
              SubscribeView()
            }
          }
          
          Button("Continue") {
            //
          }
          .buttonStyle(BlackCapsule())
          .offset(y: size.height / 2 - 32)
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Text("Restore")
            .foregroundColor(.white)
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Text("Cancel")
              .foregroundColor(.white)
          }
        }
      }
      .task {
        await PurchaseKit.shared.fetchProducts()
      }
      .background(Color.zinc900)
    }
  }
  
  @ViewBuilder
  func BrandView() -> some View {
    VStack {
      Text("EasyFocus")
//        .font(.custom(Tools.Font_MiSans_Heavy, size: 32))
      Text("Sleep, Relax, Focus Sounds")
        .font(.system(size: 20, weight: .medium))
    }
    .padding(.bottom, 32)
    .foregroundColor(.white)
  }
  
  @ViewBuilder
  func SubscribeView() -> some View {
    HStack(spacing: 16) {
      Text("\(PurchaseKit.shared.products.count)")
      ForEach(PurchaseKit.shared.products) { product in
        Group {
          if PurchaseKit.shared.product == product {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(
                Color.zinc800
                  .shadow(.drop(color: .black.opacity(0.9), radius: 12, y: 12))
                  .shadow(.inner(color: .white.opacity(0.8), radius: 1, y: 0.5))
              )
          } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(
                Color.zinc800
                  .shadow(.drop(color: .black.opacity(0.5), radius: 8))
                  .shadow(.inner(color: .white.opacity(0.8), radius: 1, y: 0.5))
              )
          }
        }
        .frame(width: 100, height: 160)
        .scaleEffect(PurchaseKit.shared.product == product ? 1.05 : 1)
        .overlay {
          VStack {
            if product.id == "co.banli.mico.easyfocus.monthly" {
              Text("Monthly")
              Text(product.displayPrice)
            }
            if product.id == "co.banli.mico.easyfocus.annual" {
              Text("1 WEEK FREE TRIAL")
              Text("Then \(product.displayPrice)/year")
            }
            if product.id == "co.banli.mico.easyfocus.lifetime" {
              Text("Lifetime")
              Text(product.displayPrice)
            }
          }
          .foregroundColor(.white)
        }
        .onTapGesture {
          withAnimation {
            PurchaseKit.shared.product = product
          }
          
          Task {
            try await PurchaseKit.shared.purchase(product)
          }
        }
      }
    }
  }
}

struct BlackCapsule: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .fontWeight(.heavy)
      .padding()
      .scaleEffect(configuration.isPressed ? 0.97 : 1)
      .background(configuration.isPressed ? Color.black.opacity(0.8) : Color.black)
      .foregroundStyle(.white)
      .clipShape(Capsule())
  }
}

#Preview {
  ProView()
}
