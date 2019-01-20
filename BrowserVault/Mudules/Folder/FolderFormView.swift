//
//  FolderFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Eureka
import RxSwift

enum FolderFormField: String {
    case name
    case enablePasscode
    case coverPhoto
}

class FolderFormView: BaseFormViewController {
    private var folderSubject: PublishSubject<FolderModel>!
    private let folder = FolderModel()
    
    convenience init(folderSubject: PublishSubject<FolderModel>) {
        self.init(nibName: nil, bundle: nil)
        self.folderSubject = folderSubject
    }
    
    override func setupFormView() {
        form = Form()
        +++ Section()
            <<< TextRow() {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.title = L10n.Folder.Name.title
                $0.placeholder = L10n.Folder.Name.placeholder
                $0.cellStyle = .subtitle
                $0.baseCell.height = { 70 }
                }.cellSetup({ (cell, _) in
                    cell.tintColor = ColorName.mainColor
                }).onChange({[weak self] (row) in
                    self?.folder.name = row.value ?? ""
                })
            <<< SwitchRow() { [weak self] in
                $0.title = L10n.Passcode.enable
                $0.value = self?.folder.enablePasscode
                $0.baseCell.height = { 60 }
                }.cellUpdate({ (cell, _) in
                    cell.switchControl?.onTintColor = ColorName.mainColor
                    cell.switchControl?.tintColor = ColorName.mainColor
                }).onChange({[weak self] (row) in
                    self?.folder.enablePasscode = row.value ?? false
                })
            <<< ImageRow(){
                $0.tag = FolderFormField.coverPhoto.rawValue
                $0.value = Asset.Folder.folder.image
                $0.title = L10n.Folder.Cover.photo
                $0.baseCell.height = { 60 }
                }.onChange({[weak self] (row) in
                    self?.folder.image = row.value
                    self?.folder.url = row.imageURL?.absoluteString
                })
            <<< ButtonRow() {
                $0.title = L10n.Generic.save
                }.cellUpdate({ (cell, _) in
                    cell.backgroundColor = ColorName.mainColor
                    cell.textLabel?.textColor = ColorName.whiteColor
                }).onCellSelection({[weak self] (_, _) in
                    guard self?.form.validate().count == 0, let folderName = self?.folder.name, folderName.count > 0 else {
                        return
                    }
                    if let folder = self?.folder {
                        self?.folderSubject.onNext(folder)
                    }
                })
    }
}
