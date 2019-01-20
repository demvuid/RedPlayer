//
//  SettingLockRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class SettingLockRouter: Router {
    func changePass() {
        let entryModule = AppModules.passcode.build()
        entryModule.router.show(from: self._view, embedInNavController: true, setupData: true)
    }
    
    func authenticatePasscodeWithCompletionBlock(_ block: ((Bool)->())?) {
        let entryModule = AppModules.passcode.build()
        entryModule.router.show(from: self._view, embedInNavController: true, setupData: block)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingLockRouter {
    var presenter: SettingLockPresenter {
        return _presenter as! SettingLockPresenter
    }
}
