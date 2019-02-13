//
//  BrowserRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/8/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class BrowserRouter: Router {
    func saveMedia(media: Media) {
        let folders = ModelManager.shared.fetchList(FolderModel.self)
        if folders.count == 0 {
            let module = AppModules.folder.build()
            module.router.show(from: self._view, embedInNavController: true, setupData: [media])
        } else {
            let module = AppModules.files.build()
            module.router.show(from: self._view, embedInNavController: true, setupData: [media])
        }
    }
    
    func openPasscodeWithCompletionBlock(_ block: ((Bool)->())?) {
        if UserSession.shared.enabledPasscode() {
            let entryModule = AppModules.passcode.build()
            entryModule.router.show(from: self._view, embedInNavController: true, setupData: block)
        } else {
            block?(true)
        }
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension BrowserRouter {
    var presenter: BrowserPresenter {
        return _presenter as! BrowserPresenter
    }
}
