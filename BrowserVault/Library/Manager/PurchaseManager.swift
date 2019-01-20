//
//  PurchaseManager.swift
//  BrowserVault
//
//  Created by HaiLe on 1/19/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import InAppPurchase
import RxSwift

private let productId = "com.amplayer.browservault.advertisement"
class PurchaseManager {
    static var shared = PurchaseManager()
    let iap = InAppPurchase.default
    var upgradeSubject = PublishSubject<Void>()
    let bag = DisposeBag()
    
    func purchaseApp(completion: @escaping (Error?)->()) {
        self.iap.purchase(productIdentifier: productId, handler: { (result) in
            // This handler is called if the payment purchased, restored, deferred or failed.
            switch result {
            case .success(let state):
                Logger.debug("purchase: \(state)")
                UserSession.shared.upgradeVersion()
                self.upgradeSubject.onNext(())
                completion(nil)
            // Handle `InAppPurchase.PaymentState`
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func restorePurchase(completion: @escaping (Error?)->()) {
        self.iap.restore(handler: { (result) in
            switch result {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func observerUpgradeVersion(hanlder: @escaping ()->()) {
        self.upgradeSubject.asObserver().subscribe(onNext: { (_) in
            hanlder()
        }).disposed(by: self.bag)
    }
    
    func observerFallback(hanlder: @escaping ()->()) {
        iap.addTransactionObserver { (state) in
            hanlder()
        }
    }
    
    func ignoreError(_ error: Error) -> Bool {
        if let error = error as? InAppPurchase.Error, error == .paymentCancelled {
            return true
        }
        return false
    }
}
