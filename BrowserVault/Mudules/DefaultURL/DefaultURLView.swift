//
//  DefaultURLView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import GoogleMobileAds

//MARK: - Public Interface Protocol
protocol DefaultURLViewInterface {
}

//MARK: DefaultURLView Class
final class DefaultURLView: BaseUserInterface {
    lazy var settingForm: DefaultURLFormView = {
        var form = DefaultURLFormView(urlSubject: self.presenter.urlSubject)
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.Browser.title
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
extension DefaultURLView: DefaultURLViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DefaultURLView {
    var presenter: DefaultURLPresenter {
        return _presenter as! DefaultURLPresenter
    }
    var displayData: DefaultURLDisplayData {
        return _displayData as! DefaultURLDisplayData
    }
}
