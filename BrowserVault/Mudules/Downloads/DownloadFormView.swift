//
//  DownloadFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 1/30/19.
//  Copyright © 2019 GreenSolution. All rights reserved.
//

import UIKit
import Eureka
import RxSwift
import RxCocoa

private enum DownloadFormFields: String {
    case fileName
    case urlRowTag
}
private enum DownloadSectionEnum: String {
    case inputURLSection
    case downloadSection
    case folderSection
}

class DownloadFormView: BaseFormViewController, DownloadFormViewProtocol {
    var observableURL: AnyObserver<(URL?, String?)>!
    var behaviourFolder: BehaviorRelay<FolderModel?>?
    private var browseType: BrowseFileType = .download
    convenience init(displayData: DownloadDisplayData) {
        self.init(nibName: nil, bundle: nil)
        self.browseType = displayData.browseType
    }
    
    override func setupFormView() {
        form = Form()
        if browseType == .download {
            form += [self.folderSection()]
        }
        if browseType != .currentDownload {
            form += [self.inputURLSection()]
        }
        if browseType != .play {
            self.form += [self.downloadSection()]
            self.handlerSubscriberDownloadModel {(index, isAdd, isUpdate, isFinish) in
                DispatchQueue.main.async {[weak self] in
                    guard let self = self else {
                        return
                    }
                    if var section = self.form.sectionBy(tag: DownloadSectionEnum.downloadSection.rawValue) {
                        if isAdd {
                            section += [self.downloadRowAtIndex(index)]
                        } else if isUpdate {
                            if index < section.endIndex {
                                section[index].reload()
                            }
                        } else if isFinish {
                            if index < section.endIndex {
                                section.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reloadFolderSection() {
        guard let section = self.form.sectionBy(tag: DownloadSectionEnum.folderSection.rawValue) else {
            return
        }
        if section.endIndex > 0 {
            section.replaceSubrange(section.startIndex..<section.endIndex, with: self.folderRows())
        } else {
            section.append(contentsOf: self.folderRows())
        }
    }
    
    func inputURLSection() -> Section {
        var section = Section() {
            $0.tag = DownloadSectionEnum.inputURLSection.rawValue
        }
        var rows = [BaseRow]()
        if self.browseType == .download {
            rows.append(TextRow() {
                $0.cellStyle = .subtitle
                $0.title = L10n.Downloads.Name.title
                $0.placeholder = L10n.Downloads.Name.place
                $0.tag = DownloadFormFields.fileName.rawValue
                $0.add(rule: RuleRequired())
                }.cellUpdate({ (cell, row) in
                    cell.height = { 70 }
                    cell.titleLabel?.font = AppBranding.UITableViewCellFont.titleLabelBold.font
                    cell.titleLabel?.textColor = ColorName.mainColor
                    cell.textField.font = AppBranding.UITableViewCellFont.contentLabel.font
                    if !row.isValid {
                        cell.titleLabel?.textColor = ColorName.errorTextColor
                    }
                }))
        }
        rows.append(URLRow() {
            $0.add(rule: RuleRequired())
//            $0.add(rule: RuleURL())
            $0.tag = DownloadFormFields.urlRowTag.rawValue
            $0.cellStyle = .subtitle
            $0.value = URL(string: "")
            $0.title = L10n.Downloads.Url.network
            $0.placeholder = L10n.Downloads.Url.place
            $0.baseCell.height = { 70 }
            }.cellUpdate({ (cell, row) in
                cell.titleLabel?.textColor = ColorName.mainColor
                if !row.isValid {
                    cell.titleLabel?.textColor = ColorName.errorTextColor
                }
            })
        )
        rows.append(ButtonRow() {
            $0.title = self.browseType == .download ? L10n.Downloads.File.download : L10n.Downloads.File.play
            }.cellUpdate({ (cell, _) in
                cell.backgroundColor = ColorName.mainColor
                cell.textLabel?.textColor = ColorName.whiteColor
            }).onCellSelection({[weak self] (_, _) in
                if self?.form.validate().count == 0 {
                    if let urlRow: URLRow = self?.form.rowBy(tag: DownloadFormFields.urlRowTag.rawValue) {
                        let nameRow: TextRow? = self?.form.rowBy(tag: DownloadFormFields.fileName.rawValue)
                        self?.observableURL?.onNext((urlRow.value, nameRow?.value))
                    }
                }
            })
        )
        section += rows
        return section
    }
    
    func downloadSection() -> Section {
        var section = Section("Downloading") { (section) in
            section.tag = DownloadSectionEnum.downloadSection.rawValue
        }
        section += self.downloadRows()
        return section
    }
    
    func downloadRows() -> [BaseRow] {
        var rows = [BaseRow]()
        for index in 0..<DownloadManager.shared.numberItemsDownload() {
            rows.append(self.downloadRowAtIndex(index))
        }
        return rows
    }
    
    func downloadRowAtIndex(_ index: Int) -> BaseRow {
        return LabelRow() {[weak self] in
            $0.cellStyle = .subtitle
            $0.baseCell.height = { 70 }
            self?.configRow($0, atIndex: index)
            }.cellUpdate({ [weak self] (cell, row) in
                cell.textLabel?.font = AppBranding.UITableViewCellFont.titleLabelBold.font
                cell.textLabel?.textColor = ColorName.mainColor
                cell.detailTextLabel?.font = AppBranding.UITableViewCellFont.contentLabel.font
                self?.configRow(row, atIndex: index)
            }).onCellSelection({ [weak self] (_, row) in
                if let index = row.indexPath?.row {
                    self?.showAppropriateActionController(atIndex: index)
                }
            })
    }
    
    func folderSection() -> Section {
        var section = Section("Save to Folder") { (section) in
            section.tag = DownloadSectionEnum.folderSection.rawValue
        }
        section += self.folderRows()
        return section
    }
    
    private func folderRows() -> [BaseRow] {
        let folders = ModelManager.shared.fetchList(FolderModel.self)
        if self.behaviourFolder?.value == nil {
           self.behaviourFolder?.accept(folders.first)
        }
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
                }.cellUpdate({ [weak self] (cell, row) in
                    if self?.behaviourFolder?.value?.id == folder.id {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
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
                    self?.behaviourFolder?.accept(folder)
                    self?.form.sectionBy(tag: DownloadSectionEnum.folderSection.rawValue)?.reload()
                })
            return row
        }
    }
}
