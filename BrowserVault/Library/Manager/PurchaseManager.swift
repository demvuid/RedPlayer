//
//  PurchaseManager.swift
//  BrowserVault
//
//  Created by HaiLe on 1/19/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStoreKit

private let productId = "com.amplayer.browservault.yearly"
private let sharedSecret = "08934d44316846d9a10d0e8f129963f2"

struct ErrorMessageResult {
    let title: String
    let message: String
}

class PurchaseManager {
    static var shared = PurchaseManager()
    var upgradeSubject = PublishSubject<Void>()
    var gettingSubscriptionSubject = PublishSubject<Void>()
    let bag = DisposeBag()
    var isUpgradePro: Bool = false
    var isTrialPeriod: Bool = false
    var expiredDate: Date? = nil
    var validDate: Date? = nil
    var receiptItemValid: ReceiptItem? = nil
    var receiptItemExpired: ReceiptItem? = nil
    
    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    debugPrint("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                debugPrint("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func upgradeVersion(isTrialPeriod: Bool = false) {
        UserSession.shared.upgradeVersion()
        self.isUpgradePro = true
        self.isTrialPeriod = isTrialPeriod
        self.enableProVersion(true)
        self.upgradeSubject.onNext(())
    }
    
    func disableProVersion() {
        UserSession.shared.disabledVersion()
        self.isUpgradePro = false
        self.isTrialPeriod = false
        self.enableProVersion(false)
        self.upgradeSubject.onNext(())
    }
    
    func purchase(_ productId: String, atomically: Bool = true, completion: @escaping (ErrorMessageResult?) -> Void) {
        SwiftyStoreKit.purchaseProduct(productId, atomically: atomically) { [weak self] result in
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self?.verifyReceipt(completion: { (_) in
                    let handler = self ?? PurchaseManager.shared
                    let errorResult = handler.alertForPurchaseResult(result)
                    completion(errorResult)
                })
            } else if case .error(let error) = result {
                debugPrint(error.localizedDescription)
                self?.disableProVersion()
                let handler = self ?? PurchaseManager.shared
                let errorResult = handler.alertForPurchaseResult(result)
                completion(errorResult)
            } else {
                let handler = self ?? PurchaseManager.shared
                let errorResult = handler.alertForPurchaseResult(result)
                completion(errorResult)
            }
        }
    }
    
    func upgradeToProVersion(_ completion: @escaping (ErrorMessageResult?) -> Void) {
        self.purchase(productId, completion: completion)
    }
    
    func restorePurchases(completion: @escaping (Bool, ErrorMessageResult) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            self?.verifyReceipt(completion: { (_) in
                let handler = self ?? PurchaseManager.shared
                let errorResult = handler.alertForRestorePurchases(results)
                completion(errorResult.0, errorResult.1)
            })
        }
    }
    
    func getInfo(_ productId: String) {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
//            self.showAlert(self.alertForProductRetrievalInfo(result))
        }
    }

    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        self.disableProVersion()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    func verifyPurchase(_ productId: String, name: String? = nil, completion: @escaping (Bool, ErrorMessageResult) -> Void) {
        verifyReceipt { result in
            let name = name ?? productId
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                let result = self.getSubscriptions(purchaseResult, name: name)
                let isPurchased: Bool = result.0
                let message = result.1
                self.gettingSubscriptionSubject.onNext(())
                completion(isPurchased, message)
                
            case .error:
                let message = self.alertForVerifyReceipt(result)
                self.gettingSubscriptionSubject.onNext(())
                completion(false, message)
            }
        }
    }
    
    func verifyAccountPro(_ completion: @escaping (Bool, ErrorMessageResult) -> Void) {
        self.isTrialPeriod = false
        self.isUpgradePro = false
        self.expiredDate = nil
        self.validDate = nil
        self.receiptItemValid = nil
        self.receiptItemExpired = nil
        self.verifyPurchase(productId, completion: completion)
    }
    
    func alertForPurchaseResult(_ result: PurchaseResult) -> ErrorMessageResult? {
        switch result {
        case .success(let purchase):
            debugPrint("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            debugPrint("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return ErrorMessageResult(title: "Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return ErrorMessageResult(title: "Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return ErrorMessageResult(title: "Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return ErrorMessageResult(title: "Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return ErrorMessageResult(title: "Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return ErrorMessageResult(title: "Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return ErrorMessageResult(title: "Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return ErrorMessageResult(title: "Purchase failed", message: "Cloud service was revoked")
            default:
                return ErrorMessageResult(title: "Purchase failed", message: (error as NSError).localizedDescription)
            }
        }
    }

    func alertForRestorePurchases(_ results: RestoreResults) -> (Bool, ErrorMessageResult) {

        if results.restoreFailedPurchases.count > 0 {
            debugPrint("Restore Failed: \(results.restoreFailedPurchases)")
            return (false, ErrorMessageResult(title: "Restore failed", message: "Unknown error. Please contact support"))
        } else if results.restoredPurchases.count > 0 {
            debugPrint("Restore Success: \(results.restoredPurchases)")
            return (true, ErrorMessageResult(title: "Purchases Restored", message: "All purchases have been restored"))
        } else {
            debugPrint("Nothing to Restore")
            return (false, ErrorMessageResult(title: "Nothing to restore", message: "No previous purchases were found"))
        }
    }
    
    func alertForProductRetrievalInfo(_ result: RetrieveResults) -> ErrorMessageResult {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return ErrorMessageResult(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        } else if let invalidProductId = result.invalidProductIDs.first {
            return ErrorMessageResult(title: "Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            return ErrorMessageResult(title: "Could not retrieve product info", message: errorString)
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> ErrorMessageResult {
        switch result {
        case .success(let receipt):
            debugPrint("Verify receipt Success: \(receipt)")
            return ErrorMessageResult(title: "Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            debugPrint("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return ErrorMessageResult(title: "Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return ErrorMessageResult(title: "Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return ErrorMessageResult(title: "Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }
    
    func getSubscriptions(_ result: VerifySubscriptionResult, name: String) -> (Bool, ErrorMessageResult) {
        switch result {
        case .purchased(let expiryDate, let items):
            self.validDate = expiryDate
            self.receiptItemValid = items.first
            self.upgradeVersion(isTrialPeriod: items.first?.isTrialPeriod == true)
            debugPrint("\(name) is valid until \(expiryDate)\n\(items)\n")
            if let item = items.first, item.isTrialPeriod == true {
                debugPrint("The customer’s subscription is in an introductory price period")
            } else {
                
            }
            return (true, ErrorMessageResult(title: "Product is purchased", message: "Product is valid until \(expiryDate)"))
        case .expired(let expiryDate, let items):
            self.expiredDate = expiryDate
            debugPrint("\(name) is expired since \(expiryDate)\n\(items)\n")
            self.receiptItemExpired = items.first
            self.disableProVersion()
            return (false, ErrorMessageResult(title: "Product expired", message: "Product is expired since \(expiryDate)"))
        case .notPurchased:
            debugPrint("\(name) has never been purchased")
            self.receiptItemExpired = nil
            self.receiptItemValid = nil
            self.disableProVersion()
            return (false, ErrorMessageResult(title: "Not purchased", message: "This product has never been purchased"))
        }
    }
    
    func observerUpgradeVersion(hanlder: @escaping ()->()) {
        self.upgradeSubject.asObserver().subscribe(onNext: { (_) in
            hanlder()
        }).disposed(by: self.bag)
    }
    
    func observerGettingSubscription(hanlder: @escaping ()->()) {
        self.gettingSubscriptionSubject.asObserver().subscribe(onNext: { (_) in
            hanlder()
        }).disposed(by: self.bag)
    }
}

extension PurchaseManager {
    func isProVersion() -> Bool {
        return UserDefaults.standard.bool(forKey: productId) == true
    }
    
    func enableProVersion(_ enable: Bool) {
        UserDefaults.standard.set(enable, forKey: productId)
        UserDefaults.standard.synchronize()
    }
    
    func shouldGettingVersion() -> Bool {
        return UserDefaults.standard.object(forKey: productId) == nil
    }
}
