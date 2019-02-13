//
//  DownloadPresenter.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import Foundation
import Viperit
import RxSwift

class DownloadPresenter: Presenter {
    var observableURL: AnyObserver<(URL?, String?)> {
        return AnyObserver<(URL?, String?)>(eventHandler: { [weak self] event in
            switch event {
            case .next((let url, let fileName)):
                if var url = url, url.absoluteString.isValidURL {
                    ParseVideoManager.shared.parseVideoLinkURL(url.absoluteString, handler: { (urlString, error) in
                        if let urlString = urlString, let linkURL = URL(string: urlString) {
                            url = linkURL
                        }
                        if self?.view.browseType() == .download {
                            self?.view.handlerDownloadURL(url, fileName: fileName)
                        } else {
                            DispatchQueue.main.async {[weak self] in
                                self?.view.handlerPlayerURL(url.absoluteString)
                            }
                        }
                    })
                } else {
                    self?._view.showAlertWith(title: L10n.Generic.Error.Alert.title, messsage: L10n.Settings.Browser.Url.required)
                }
            default: break
            }
        })
    }
    private var saveableFolder: FolderModel!
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
        DownloadManager.shared.addHandlerDownloadedMedia { [weak self] media in
            if let folder = self?.saveableFolder {
                self?.interactor.importedMedias([media], inFolder: folder, completionBlock: { (medias) in
                    self?.saveableFolder = nil
                    self?.cancelScreen()
                })
            } else {
                self?.router.saveMedia(media)
            }
        }
    }
    
    override func setupView(data: Any) {
        if let folder = data as? FolderModel {
            self.saveableFolder = folder
        }
    }
}


// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadPresenter {
    var view: DownloadViewInterface {
        return _view as! DownloadViewInterface
    }
    var interactor: DownloadInteractor {
        return _interactor as! DownloadInteractor
    }
    var router: DownloadRouter {
        return _router as! DownloadRouter
    }
}
