
//
//  SettingLockView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol SettingLockViewInterface {
}

//MARK: SettingLockView Class
final class SettingLockView: UserInterface {
    lazy var settingForm: SettingLockFormView = {
        var form = SettingLockFormView(changePassSubject: self.presenter.changePassSubject)
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.Lock.title
        self.view.addSubview(self.settingForm.view)
        self.addChild(self.settingForm)
    }
}

//MARK: - Public interface
extension SettingLockView: SettingLockViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension SettingLockView {
    var presenter: SettingLockPresenter {
        return _presenter as! SettingLockPresenter
    }
    var displayData: SettingLockDisplayData {
        return _displayData as! SettingLockDisplayData
    }
}
