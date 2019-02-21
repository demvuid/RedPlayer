//
//  YoutubePresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 2/18/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class YoutubePresenter: Presenter {
    @objc func changeCategories() {
        self.router.changeCategories()
    }
    
    func playVideoById(_ videoId: String, duration: String = "") {
        self._view.startActivityLoading()
        self.interactor.fetchVideoById(videoId, duration: duration)
    }
    
    func fetchedInfoVideo(videoURL: String?, error: Error?) {
        DispatchQueue.main.async {[weak self] in
            self?._view.stopActivityLoading()
            if let url = videoURL {
                self?.router.playVideoURL(urlString: url)
            } else if let error = error {
                self?._view.showAlertWith(errorString: error.localizedDescription)
            }
        }
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension YoutubePresenter {
    var view: YoutubeViewInterface {
        return _view as! YoutubeViewInterface
    }
    var interactor: YoutubeInteractor {
        return _interactor as! YoutubeInteractor
    }
    var router: YoutubeRouter {
        return _router as! YoutubeRouter
    }
}
