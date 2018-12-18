//
//  SettingsRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/9/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class SettingsRouter: Router {
    func settingsDefaultURL() {
        let module = AppModules.defaultURL.build()
        module.router.show(from: self._view)
    }
    
    func settingLock() {
        let module = AppModules.settingLock.build()
        module.router.show(from: self._view)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingsRouter {
    var presenter: SettingsPresenter {
        return _presenter as! SettingsPresenter
    }
}
