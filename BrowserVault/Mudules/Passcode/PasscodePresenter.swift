//
//  PasscodePresenter.swift
//  LifeSite
//
//  Created by Thanh Duong on 6/21/18.
//Copyright © 2018 Evizi. All rights reserved.
//

import Foundation
import Viperit

class PasscodePresenter: Presenter {
    var completionBlock: ((Bool)->())? = nil
    override func viewHasLoaded() {
        super.viewHasLoaded()
        view.configUI()
    }
    
    func presentAlert(title: String?, message: String) {
        _view.showAlertWith(title: title, message: message)
    }
    
    func verifiedPasscode() {
        if completionBlock != nil {
            completionBlock!(true)
            self.router.cancelScreen()
        } else {
            self.router.gotoDashboard()
        }
    }
    
    @objc func cancelScreen() {
        if completionBlock != nil {
            completionBlock!(false)
        }
        self.router.cancelScreen()
    }
    
    func authenticateUser() {
        self.interactor.authenticateUser()
    }
    
    func savePasscode(passcode: String) {
        interactor.setPasscode(passcode: passcode)
    }
    
    func configUI() {
        view.configUI()
    }
    
    func getPasscode() -> String {
        return interactor.getPasscode()
    }
    
    func configTextField(textField: PasscodelField, numberOfDigits: Int) {
        view.configTextField(textField: textField, numberOfDigits: numberOfDigits)
    }
    
    func setupEnterPasscode() {
        view.setupEnterPasscode()
    }
    
    func setupCreatePasscode() {
        view.setupCreatePasscode()
    }
    
    func setupVerifyPasscode() {
        view.setupVerifyPasscode()
    }
    
    override func setupView(data: Any) {
        if let block = data as? ((Bool)->()) {
            self.completionBlock = block
        } else {
            self.view.updateConfigPass(data: data)
        }
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PasscodePresenter {
    var view: PasscodeViewInterface {
        return _view as! PasscodeViewInterface
    }
    var interactor: PasscodeInteractor {
        return _interactor as! PasscodeInteractor
    }
    var router: PasscodeRouter {
        return _router as! PasscodeRouter
    }
}
