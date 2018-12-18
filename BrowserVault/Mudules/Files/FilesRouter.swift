//
//  FilesRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class FilesRouter: Router {
    func addFolder() {
        let module = AppModules.folder.build()
        module.router.show(from: self._view, embedInNavController: true)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesRouter {
    var presenter: FilesPresenter {
        return _presenter as! FilesPresenter
    }
}
