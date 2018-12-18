//
//  TabBrowserView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/13/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol TabBrowserViewInterface {
}

//MARK: TabBrowserView Class
final class TabBrowserView: UserInterface {
}

//MARK: - Public interface
extension TabBrowserView: TabBrowserViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension TabBrowserView {
    var presenter: TabBrowserPresenter {
        return _presenter as! TabBrowserPresenter
    }
    var displayData: TabBrowserDisplayData {
        return _displayData as! TabBrowserDisplayData
    }
}
