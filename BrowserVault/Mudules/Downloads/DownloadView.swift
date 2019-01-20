//
//  DownloadView.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol DownloadViewInterface {
}

//MARK: DownloadView Class
final class DownloadView: UserInterface {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
        self.navigationItem.title = L10n.Downloads.title
    }
}

//MARK: - Public interface
extension DownloadView: DownloadViewInterface {
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadView {
    var presenter: DownloadPresenter {
        return _presenter as! DownloadPresenter
    }
    var displayData: DownloadDisplayData {
        return _displayData as! DownloadDisplayData
    }
}
