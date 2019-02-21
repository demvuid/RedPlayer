//
//  YoutubeRouter.swift
//  BrowserVault
//
//  Created by HaiLe on 2/18/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class YoutubeRouter: Router {
    func changeCategories() {
        if let controller = self._view.storyboard?.instantiateViewController(withIdentifier: "ListGroupYoutubeViewController") as? ListGroupYoutubeViewController {
            controller.delegate = self._view as? YoutubeViewInterface
            self._view.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func playVideoURL(urlString: String) {
        NavigationManager.shared.showMediaPlayerURL(urlString)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension YoutubeRouter {
    var presenter: YoutubePresenter {
        return _presenter as! YoutubePresenter
    }
}
