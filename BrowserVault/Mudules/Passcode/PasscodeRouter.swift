//
//  PasscodeRouter.swift
//  LifeSite
//
//  Created by Thanh Duong on 6/21/18.
//Copyright © 2018 Evizi. All rights reserved.
//

import Foundation
import Viperit

class PasscodeRouter: Router {
    func gotoDashboard() {
        let module = AppModules.dashboard.build()
        module.router.show(inWindow: UIApplication.shared.keyWindow)
    }
    
    func cancelScreen() {
        self._view.dismiss(animated: true, completion: nil)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PasscodeRouter {
    var presenter: PasscodePresenter {
        return _presenter as! PasscodePresenter
    }
}
