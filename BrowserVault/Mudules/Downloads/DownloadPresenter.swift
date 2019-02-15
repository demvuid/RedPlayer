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
                    self?._view.startActivityLoading()
                    ParseVideoManager.shared.parseVideoLinkURL(url.absoluteString, handler: { [weak self] (urlString, error) in
                        DispatchQueue.main.async {[weak self] in
                            self?._view.stopActivityLoading()
                        }
                        if let urlString = urlString, let linkURL = URL(string: urlString) {
                            url = linkURL
                        }
                        if self?.view.browseType() == .download {
                            guard fileName?.fileExtension() != "" &&  (fileName?.isMediaFileExtension == true || fileName?.isImageFileExtension == true) else {
                                self?._view.showAlertWith(title: "Invalid File Extention", messsage: "Sorry, File name is not contained a media extention.\nPlease check the correct name.")
                                return
                            }
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
    
    @objc func cancelScreen() {
        self.router.cancelScreen()
    }
    
    override func viewHasLoaded() {
        super.viewHasLoaded()
    }
    
    override func setupView(data: Any) {
        if let folder = data as? FolderModel {
            self.view.updateSaveableFolder(folder)
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
