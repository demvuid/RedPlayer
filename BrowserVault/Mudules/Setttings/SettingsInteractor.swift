//
//  SettingsInteractor.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class SettingsInteractor: Interactor {
    func purchaseApp() {
//        PurchaseManager.shared.purchaseApp { (error) in
//            if let error = error {
//                self.presenter.alertError(error)
//            } else {
//                self.presenter.purchasedApp()
//            }
//        }
    }
    
    func restoreApp() {
//        PurchaseManager.shared.restorePurchase(completion: { (error) in
//            if let error = error {
//                self.presenter.alertError(error)
//            } else {
//                self.presenter.restorePurchasedApp()
//            }
//        })
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingsInteractor {
    var presenter: SettingsPresenter {
        return _presenter as! SettingsPresenter
    }
}
