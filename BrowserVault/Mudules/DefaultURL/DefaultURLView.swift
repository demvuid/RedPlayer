//
//  DefaultURLView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol DefaultURLViewInterface {
}

//MARK: DefaultURLView Class
final class DefaultURLView: UserInterface {
    lazy var settingForm: DefaultURLFormView = {
        var form = DefaultURLFormView(urlSubject: self.presenter.urlSubject)
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.Browser.title
        self.view.addSubview(self.settingForm.view)
        self.addChild(self.settingForm)
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
