//
//  PurchaseKit.swift
//  EasyFocus
//
//  Created by DBL on 2025/5/12.
//

import SwiftUI
import StoreKit

@Observable
class PurchaseKit {
  static let shared = PurchaseKit()
  var product: Product?
  var products: [Product] = []
  var productIDs: [String] = ["co.banli.mico.easyfocus.monthly"]
  var updates: Task<Void, Never>?
  var transactions: Set<StoreKit.Transaction> = []
  var isSubscribed: Bool {
    transactions.contains { $0.ownershipType == .purchased || $0.ownershipType == .familyShared }
  }
  
  init() {
    updates = Task {
      for await update in StoreKit.Transaction.updates {
        if let transaction = try? update.payloadValue {
          await fetchTransactions()
          await transaction.finish()
        }
      }
    }
  }
  
  deinit {
    updates?.cancel()
  }
  
  func fetchProducts() async {
    do {
      products = try await Product.products(for: productIDs)
      products = products.sorted {
        if let aIndex = productIDs.firstIndex(of: $0.id), let bIndex = productIDs.firstIndex(of: $1.id) {
          aIndex < bIndex
        } else {
          false
        }
      }
      print("products", products)
      products.forEach { product in
        switch product.type {
        case .autoRenewable:
          print("autoRenewable", product.displayName, product.displayPrice)
          break
        case .consumable:
          print("consumable", product.displayName, product.displayPrice)
          break
        case .nonConsumable:
          print("nonConsumable", product.displayName, product.displayPrice)
          break
        default:
          print("Unknown product with identifier \(product.id)")
        }
      }
    } catch {
      print("Failed - error retrieving products \(error.localizedDescription)")
    }
  }
  
  func purchase(_ product: Product) async throws {
    let result = try await product.purchase()

    switch result {
    case .success(let verificationResult):
      if let transaction = try? verificationResult.payloadValue {
        transactions.insert(transaction)
        await transaction.finish()
      }
    case .userCancelled:
      print("user cancelled")
      break
    case .pending:
      print("pending")
      break
    @unknown default:
      break
    }
  }
  
  func fetchTransactions() async {
    var transactions: Set<StoreKit.Transaction> = []
    
    for await entitlement in StoreKit.Transaction.currentEntitlements {
      if let transaction = try? entitlement.payloadValue {
        transactions.insert(transaction)
      }
    }
    
    self.transactions = transactions
    print("transactions", transactions.map { $0.productID })
//    Store.isSubscribed = transactions.contains { $0.ownershipType == .purchased || $0.ownershipType == .familyShared }
  }
}
