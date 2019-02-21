//
//  DownloadView.swift
//  BrowserVault
//
//  Created by HaiLe on 1/29/19.
//Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import GoogleMobileAds
import RxSwift
import RxCocoa

//MARK: - Public Interface Protocol
protocol DownloadViewInterface {
    func browseType() -> BrowseFileType
    func handlerPlayerURL(_ url: String)
    func handlerDownloadURL(_ url: URL, fileName: String?)
    func updateSaveableFolder(_ folder: FolderModel)
    
}

//MARK: DownloadView Class
final class DownloadView: BaseUserInterface {
    lazy var formView: DownloadFormView = {
        var form = DownloadFormView(displayData: self.displayData)
        form.observableURL = self.presenter.observableURL
        form.behaviourFolder = self.behaviourFolder
        return form
    }()
    
    var behaviourFolder = BehaviorRelay<FolderModel?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
        if self.browseType() == .play {
            self.navigationItem.title = L10n.Options.Play.title
        } else {
            self.navigationItem.title = L10n.Downloads.title
        }
        self.view.addSubview(self.formView.view)
        self.addChild(self.formView)
        self.showBanner()
        PurchaseManager.shared.observerUpgradeVersion {[weak self] in
            self?.formView.tableView.tableHeaderView = nil
        }
        NavigationManager.shared.createAndLoadAdvertise()
    }
    
    override func showBannerView(_ bannerView: GADBannerView) {
        self.formView.tableView.tableHeaderView = bannerView
    }
}

//MARK: - Public interface
extension DownloadView: DownloadViewInterface {
    func browseType() -> BrowseFileType {
        return displayData.browseType
    }
    
    func handlerPlayerURL(_ url: String) {
        NavigationManager.shared.showMediaPlayerURL(url)
    }
    
    func handlerDownloadURL(_ url: URL, fileName: String?) {
        var countPresentAdv = UserSession.shared.countPlayVideo
        if countPresentAdv >= 2 {
            countPresentAdv = 0
        } else {
            countPresentAdv += 1
        }
        UserSession.shared.countPlayVideo = countPresentAdv
        if countPresentAdv == 0 {
            NavigationManager.shared.handlerDismissAdvertisement = {[weak self] in
                guard let self = self else { return }
                DownloadManager.shared.downloadURL(url,
                                                   name: fileName,
                                                   inFolder: self.behaviourFolder.value,
                                                   handler: {[weak self] in
                                                    self?.formView.reloadFolderSection()
                })
                self.presenter.cancelScreen()
            }
            NavigationManager.shared.presentAdverstive()
        } else {
            DownloadManager.shared.downloadURL(url,
                                               name: fileName,
                                               inFolder: self.behaviourFolder.value,
                                               handler: {[weak self] in
                                                self?.formView.reloadFolderSection()
            })
            self.presenter.cancelScreen()
        }
    }
    
    func updateSaveableFolder(_ folder: FolderModel) {
        self.behaviourFolder.accept(folder)
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension DownloadView {
    var presenter: DownloadPresenter {
        return _presenter as! DownloadPresenter
    }
    var displayData: DownloadDisplayData {
        return _displayData as! DownloadDisplayData
    }
}
