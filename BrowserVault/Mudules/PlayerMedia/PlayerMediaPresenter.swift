//
//  PlayerMediaPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 12/26/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class PlayerMediaPresenter: Presenter {
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        self.view.playMediaURL()
        NavigationManager.shared.createAndLoadAdvertise()
        NavigationManager.shared.handlerDismissAdvertisement = {[weak self] in
            self?.view.startPlayVideo()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NavigationManager.shared.presentAdverstive()
        }
    }
    
    override func setupView(data: Any) {
        if let url = data as? String {
            self.view.updatePlayerURL(url)
        }
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension PlayerMediaPresenter {
    var view: PlayerMediaViewInterface {
        return _view as! PlayerMediaViewInterface
    }
    var interactor: PlayerMediaInteractor {
        return _interactor as! PlayerMediaInteractor
    }
    var router: PlayerMediaRouter {
        return _router as! PlayerMediaRouter
    }
}
