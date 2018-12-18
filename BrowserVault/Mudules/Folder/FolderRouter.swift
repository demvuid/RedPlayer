//
//  FolderRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class FolderRouter: Router {
    func cancelScreen() {
        self._view.dismiss(animated: true, completion: nil)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FolderRouter {
    var presenter: FolderPresenter {
        return _presenter as! FolderPresenter
    }
}
