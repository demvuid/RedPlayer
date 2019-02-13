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

private enum DownloadFormFields: String {
    case fileName
    case urlRowTag
}
private enum DownloadSectionEnum: String {
    case inputURLSection
    case downloadSection
}

class DownloadFormView: BaseFormViewController, DownloadFormViewProtocol {
    var observableURL: AnyObserver<(URL?, String?)>!
    private var browseType: BrowseFileType = .download
    convenience init(displayData: DownloadDisplayData) {
        self.init(nibName: nil, bundle: nil)
        self.browseType = displayData.browseType
    }
    
    override func setupFormView() {
        form = Form()
        +++ self.inputURLSection()
        +++ self.downloadSection()
        self.handlerSubscriberDownloadModel { [weak self] (tag, isAdd, isUpdate, isFinish) in
            guard let self = self, let section = self.form.sectionBy(tag: DownloadSectionEnum.downloadSection.rawValue) else { return}
            if isAdd {
                if section.endIndex < DownloadManager.shared.numberItemsDownload() {
                    if section.endIndex > 0 {
                        section.replaceSubrange(section.startIndex..<section.endIndex, with: self.downloadRows())
                    } else {
                        section.append(contentsOf: self.downloadRows())
                    }
                }
            } else if isUpdate, let tag = tag {
                if let row: TextRow = self.form.rowBy(tag: tag) {
                    row.reload()
                }
            } else if isFinish, let tag = tag {
                if let row: TextRow = self.form.rowBy(tag: tag), let indexPath = row.indexPath {
                    section.remove(at: indexPath.row)
                }
            }
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
            $0.add(rule: RuleURL())
            $0.tag = DownloadFormFields.urlRowTag.rawValue
            $0.cellStyle = .subtitle
            $0.title = L10n.Downloads.Url.network
            $0.placeholder = L10n.Downloads.Url.place
            $0.value = URL(string: "https://www.youtube.com/watch?v=o_XVt5rdpFY")
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
        var section = Section() {
            $0.tag = DownloadSectionEnum.downloadSection.rawValue
            $0.header?.title = "Downloads"
        }
        
        section += self.downloadRows()
        return section
    }
    
    func downloadRows() -> [BaseRow] {
        var rows = [BaseRow]()
        for index in 0..<DownloadManager.shared.numberItemsDownload() {
            rows.append(TextRow() {
                $0.cellStyle = .subtitle
                }.cellSetup({ (_, row) in
                    row.cellStyle = .subtitle
                }).cellUpdate({ [weak self] (cell, row) in
                    cell.height = { 70 }
                    row.cellStyle = .subtitle
                    cell.titleLabel?.font = AppBranding.UITableViewCellFont.titleLabelBold.font
                    cell.titleLabel?.textColor = ColorName.mainColor
                    cell.textField.font = AppBranding.UITableViewCellFont.contentLabel.font
                    self?.configRow(row, atIndex: index)
                    cell.isUserInteractionEnabled = false
                }))
        }
        return rows
    }

}
