//
//  FilesView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit
import GoogleMobileAds

//MARK: - Public Interface Protocol
protocol FilesViewInterface {
    func reloadView()
    func showAdverstive()
}

//MARK: FilesView Class
final class FilesView: BaseUserInterface {
    lazy var filesForm: FilesFormView = {
        var form = FilesFormView(folders: self.presenter.getListFolders(), handlerDeleteFolder: self.presenter.handlerDeleteFolder)
        form.folderSubject = self.presenter.folderSubject
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Folder.title
        
        if self.presenter.isAddFile {
            self.navigationItem.title = L10n.Folder.select
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self.presenter, action: #selector(self.presenter.cancelScreen))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self.presenter, action: #selector(self.presenter.addFolder))
            self.updateEditButton()
        }
        self.showBanner()
        NavigationManager.shared.createAndLoadAdvertise()
        DownloadManager.shared.addHandlerRefreshFolder { (_) in
            self.filesForm.reloadFolders(self.presenter.getListFolders())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.view.subviews.contains(self.filesForm.view) {
            self.filesForm.reloadFolders(self.presenter.getListFolders())
        } else {
            self.view.addSubview(self.filesForm.view)
            self.addChild(self.filesForm)
        }
    }
    
    private func updateEditButton() {
        let sytemItem: UIBarButtonItem.SystemItem = self.filesForm.tableView?.isEditing == true ? .done : .edit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: sytemItem, target: self, action: #selector(self.editView))
    }
    
    @objc func editView() {
        self.filesForm.tableView.setEditing(!self.filesForm.tableView.isEditing, animated: true)
        self.updateEditButton()
    }
    
    override func showBannerView(_ bannerView: GADBannerView) {
        self.filesForm.tableView.tableHeaderView = bannerView
    }
}


//MARK: - Public interface
extension FilesView: FilesViewInterface {
    func reloadView() {
        self.filesForm.reloadFolders(self.presenter.getListFolders())
    }
    
    func showAdverstive() {
        NavigationManager.shared.presentAdverstive()
    }
}

// MARK: - VIPER COMPONENTS API (Auto-generated code)
private extension FilesView {
    var presenter: FilesPresenter {
        return _presenter as! FilesPresenter
    }
    var displayData: FilesDisplayData {
        return _displayData as! FilesDisplayData
    }
}
