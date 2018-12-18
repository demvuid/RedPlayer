//
//  FilesView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/12/18.
//Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit
import Viperit

//MARK: - Public Interface Protocol
protocol FilesViewInterface {
}

//MARK: FilesView Class
final class FilesView: UserInterface {
    lazy var filesForm: FilesFormView = {
        var form = FilesFormView(folders: self.presenter.getListFolders())
        return form
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = L10n.Settings.title
        self.navigationItem.title = L10n.Folder.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self.presenter, action: #selector(self.presenter.addFolder))
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
}

//MARK: - Public interface
extension FilesView: FilesViewInterface {
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
