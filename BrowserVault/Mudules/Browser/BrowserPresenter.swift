//
//  BrowserPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/8/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class BrowserPresenter: Presenter {
    func saveMedia(media: Media) {
        self.router.saveMedia(media: media)
    }
    
    func openPasscodeWithCompletionBlock(_ block: ((Bool)->())?) {
        self.router.openPasscodeWithCompletionBlock(block)
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension BrowserPresenter {
    var view: BrowserViewInterface {
        return _view as! BrowserViewInterface
    }
    var interactor: BrowserInteractor {
        return _interactor as! BrowserInteractor
    }
    var router: BrowserRouter {
        return _router as! BrowserRouter
    }
}
