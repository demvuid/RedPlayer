//
//  PasscodeInteractor.swift
//  LifeSite
//
//  Created by Thanh Duong on 6/21/18.
//Copyright © 2018 Evizi. All rights reserved.
//

import Foundation
import Viperit

class PasscodeInteractor: Interactor {
    func setPasscode(passcode: String) {
        UserSession.shared.setPasscode(passcode: passcode)
    }
    
    func getPasscode() -> String {
        guard let passcode = UserSession.shared.decryptedPasscode() else {
            return ""
        }
        return passcode
    }
    
    func authenticateUser() {
        AuthenticationManager.shared.authenticate { (success, error) in
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                if success {
                    self.presenter.gotoDashboard()
                } else if let message = error?.localizedDescription {
                    self.presenter.presentAlert(title: L10n.Generic.Error.Alert.title, message: message)
                }
            }
        }
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PasscodeInteractor {
    var presenter: PasscodePresenter {
        return _presenter as! PasscodePresenter
    }
}
