
//
//  SettingLockView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import GoogleMobileAds

//MARK: - Public Interface Protocol
protocol SettingLockViewInterface {
}

//MARK: SettingLockView Class
final class SettingLockView: BaseUserInterface {
    lazy var settingForm: SettingLockFormView = {
        var form = SettingLockFormView(changePassSubject: self.presenter.changePassSubject)
        form.authenticatePassSubject = self.presenter.authenticateSubject
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.Lock.title
        self.view.addSubview(self.settingForm.view)
        self.addChild(self.settingForm)
        self.showBanner()
        PurchaseManager.shared.observerUpgradeVersion {[weak self] in
            self?.settingForm.tableView.tableHeaderView = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func showBannerView(_ bannerView: GADBannerView) {
        self.settingForm.tableView.tableHeaderView = bannerView
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
