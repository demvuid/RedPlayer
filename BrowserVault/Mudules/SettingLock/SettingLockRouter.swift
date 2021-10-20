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
        entryModule.presenter.setupView(data: true)
        let controller = entryModule.router.embedInNavigationController()
        controller.modalPresentationStyle = .fullScreen
        self._view.present(controller, animated: true, completion: nil)
    }
    
    func authenticatePasscodeWithCompletionBlock(_ block: ((Bool)->())?) {
        let entryModule = AppModules.passcode.build()
        entryModule.presenter.setupView(data: block)
        let controller = entryModule.router.embedInNavigationController()
        controller.modalPresentationStyle = .fullScreen
        self._view.present(controller, animated: true, completion: nil)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingLockRouter {
    var presenter: SettingLockPresenter {
        return _presenter as! SettingLockPresenter
    }
}
