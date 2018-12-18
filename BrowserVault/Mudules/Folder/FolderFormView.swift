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
    private var enablePasscode: Bool = false
    private var folderName: String? = nil
    private var folderSubject: PublishSubject<FolderModel>!
    
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
                }.onChange({[weak self] (row) in
                    self?.folderName = row.value
                })
            <<< SwitchRow() { [unowned self] in
                $0.title = L10n.Passcode.enable
                $0.value = self.enablePasscode
                $0.baseCell.height = { 60 }
                }.cellUpdate({ (cell, _) in
                    cell.switchControl?.tintColor = ColorName.mainColor
                }).onChange({[unowned self] (row) in
                    self.enablePasscode = row.value ?? false
                })
            <<< ImageRow(){
                $0.tag = FolderFormField.coverPhoto.rawValue
                $0.value = Asset.Folder.folder.image
                $0.title = L10n.Folder.Cover.photo
                $0.baseCell.height = { 60 }
                }
            <<< ButtonRow() {
                $0.title = L10n.Generic.save
                }.cellUpdate({ (cell, _) in
                    cell.backgroundColor = ColorName.mainColor
                    cell.textLabel?.textColor = ColorName.whiteColor
                }).onCellSelection({[weak self] (_, _) in
                    guard self?.form.validate().count == 0, let folderName = self?.folderName else {
                        return
                    }
                    let folder = FolderModel()
                    folder.name = folderName
                    folder.enablePasscode = self?.enablePasscode ?? false
                    let coverPhoto: ImageRow? = self?.form.rowBy(tag: FolderFormField.coverPhoto.rawValue)
                    folder.image = coverPhoto?.value
                    folder.url = coverPhoto?.imageURL?.absoluteString
                    self?.folderSubject.onNext(folder)
                })
    }
}
