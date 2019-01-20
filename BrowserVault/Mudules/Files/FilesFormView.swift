//
//  FilesFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/18/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Eureka
import RxSwift

class FilesFormView: BaseFormViewController {
    private var folders = [FolderModel]()
    var folderSubject: PublishSubject<FolderModel>!
    private var handlerDeleteFolder: ((FolderModel)->())?
    
    convenience init(folders: [FolderModel], handlerDeleteFolder handler: ((FolderModel)->())?) {
        self.init(nibName: nil, bundle: nil)
        self.folders.append(contentsOf: folders)
        self.handlerDeleteFolder = handler
    }
    
    override func setupFormView() {
        form = Form()
        var section = Section()
        section += self.generateRows()
        form +++ section
    }
    
    func reloadFolders(_ folders: [FolderModel]) {
        self.folders.removeAll()
        self.folders.append(contentsOf: folders)
        self.viewWillAppear(true)
        if let section = self.form.allSections.first {
            section.replaceSubrange(section.startIndex..<section.endIndex, with: self.generateRows())
        }
    }
    
    private func generateRows() -> [BaseRow] {
        return folders.map { (folder) -> LabelRow in
            let row = LabelRow() {
                $0.tag = folder.id
                $0.title = "\(folder.name)"
                $0.cellStyle = .subtitle
                if let imageURL = folder.imageURL, let image = UIImage(contentsOfFile: imageURL.path)?.resizeTo(newSize: CGSize(width: 60, height: 50)) {
                    $0.baseCell.imageView?.image = image
                } else {
                    $0.baseCell.imageView?.image = Asset.Folder.folder.image.resizeTo(newSize: CGSize(width: 60, height: 50))
                }
                $0.baseCell.height = { 70 }
                }.cellUpdate({ (cell, row) in
                    cell.accessoryType = .disclosureIndicator
                    let font = AppBranding.baseFont
                    let color = ColorName.subTitleColor
                    let subTitle: String = folder.medias.count <= 1 ? L10n.Folder.File.number(folder.medias.count) : L10n.Folder.Files.number(folder.medias.count)
                    let attributeString = NSAttributedString(string: subTitle, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
                    if folder.enablePasscode {
                        let imageAttribute = NSTextAttachment.attributedString(image: Asset.Folder.lockOutline.image, font: font, width: 20, color: color)
                        let mutableAttributeString = NSMutableAttributedString(attributedString: attributeString)
                        mutableAttributeString.append(NSAttributedString(string: " "))
                        mutableAttributeString.append(imageAttribute)
                        cell.detailTextLabel?.attributedText = mutableAttributeString
                    } else {
                        cell.detailTextLabel?.attributedText = attributeString
                    }
                }).onCellSelection({[weak self] (_, _) in
                    self?.folderSubject?.onNext(folder)
                })
            if !folder.isLibrary {
                let deleteAction = SwipeAction(style: .destructive, title: L10n.Generic.delete) {[weak self] (_, _, completionHandler) in
                    guard let self = self else {return }
                    self.showAlertWith(title: L10n.Generic.warning, message: L10n.Folder.Files.Confirm.delete, cancelTitle: L10n.Generic.Button.Title.cancel, cancelBlock: { (_) in
                        completionHandler?(false)
                    }, destrucionTitle: L10n.Generic.delete, destructionBlock: {[weak self] (_) in
                        guard let self = self else { return }
                        let index = self.folders.firstIndex(where: {$0.id == folder.id})
                        self.handlerDeleteFolder?(folder)
                        completionHandler?(true)
                        if let index = index, index < self.folders.count {
                            self.folders.remove(at: index)
                        }
                        if self.folders.count > 0 {
                            self.viewWillAppear(true)
                            if let section = self.form.allSections.first {
                                section.replaceSubrange(section.startIndex..<section.endIndex, with: self.generateRows())
                            }
                        }
                        
                    })
                }
                row.trailingSwipe.actions = [deleteAction]
            }
            return row
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let actions = super.tableView(tableView, editActionsForRowAt: indexPath)
        if actions == nil && form[indexPath].trailingSwipe.actions.count > 0  {
            if #available(iOS 11, *) {
                if let actionConfig = super.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath) {
                    var rowActions = [UITableViewRowAction]()
                    actionConfig.actions.forEach { (action) in
                        var style: UITableViewRowAction.Style = .default
                        if action.style == .destructive {
                            style = .destructive
                        } else if action.style == .normal {
                            style = .normal
                        }
                        let title = action.title
                        let handler = action.handler
                        let rowAction = UITableViewRowAction(style: style, title: title, handler: {[unowned self] (rowAction, indexPath) in
                            handler(action, self.form[indexPath].baseCell, { completion in
                            })
                        })
                        rowActions.append(rowAction)
                    }
                    return rowActions
                }
            }
        }
        return actions
    }
}
