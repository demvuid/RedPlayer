//
//  DownloadRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class DownloadRouter: Router {
    func cancelScreen() {
        self._view.dismiss(animated: true, completion: nil)
    }
    
    func saveMedia(_ media: Media) {
        let module = AppModules.files.build()
        module.router.show(from: self._view, setupData: [media])
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadRouter {
    var presenter: DownloadPresenter {
        return _presenter as! DownloadPresenter
    }
}
