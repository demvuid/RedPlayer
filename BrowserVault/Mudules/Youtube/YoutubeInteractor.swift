//
//  YoutubeInteractor.swift
//  BrowserVault
//
//  Created by HaiLe on 2/18/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit

class YoutubeInteractor: Interactor {
    
    func fetchVideoById(_ videoId: String, duration: String = "") {
        ParseVideoManager.shared.parseVideoById(videoId, duration: duration) { [weak self] (urlString, error) in
            
            self?.presenter.fetchedInfoVideo(videoURL: urlString, error: error)
        }
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension YoutubeInteractor {
    var presenter: YoutubePresenter {
        return _presenter as! YoutubePresenter
    }
}
