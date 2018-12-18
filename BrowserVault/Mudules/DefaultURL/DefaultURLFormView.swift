//
//  DefaultURLFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Eureka
import RxSwift

private let SearchEngineTag = "SearchEngineTag"
class DefaultURLFormView: BaseFormViewController {
    private var isCustomURL: Bool = true
    private var url: String? = nil
    private var urlSubject: PublishSubject<String>!
    private var searchEngineArray = ["https://google.com", "https://www.bing.com", "https://yahoo.com"]
    
    convenience init(urlSubject: PublishSubject<String>) {
        self.init(nibName: nil, bundle: nil)
        self.urlSubject = urlSubject
        if let _ = searchEngineArray.filter({ $0 == self.defaultURLString }).first {
            self.isCustomURL = false
            self.url = nil
        } else {
            self.url = self.defaultURLString
            self.isCustomURL = true
        }
    }
    
    override func setupFormView() {
        form = Form()
        form += self.generateSections()
    }
    
    func inputURLRows() -> [BaseRow] {
        var rows = [BaseRow]()
        rows.append(URLRow() {[unowned self] in
            $0.add(rule: RuleURL())
            if let url = self.url {
                $0.value = URL(string: url)
            }
            $0.cellStyle = .subtitle
            $0.title = L10n.Settings.Browser.Url.custom
            $0.placeholder = L10n.Settings.Browser.Url.input
            $0.baseCell.height = { 70 }
            }.onChange({[weak self] (row) in
                self?.url = row.value?.absoluteString
            })
        )
        rows.append(ButtonRow() {
            $0.title = L10n.Settings.Browser.Url.set
            }.cellUpdate({ (cell, _) in
                cell.backgroundColor = ColorName.mainColor
                cell.textLabel?.textColor = ColorName.whiteColor
            }).onCellSelection({[weak self] (_, _) in
                if let url = self?.url {
                    self?.urlSubject.onNext(url)
                }
            })
        )
        return rows
    }
    
    func searchEngineRows() -> [BaseRow] {
        return searchEngineArray.map { (searchURL) -> BaseRow in
            return LabelRow() {
                var title = searchURL.replacingOccurrences(of: "https://www.", with: "")
                title = title.replacingOccurrences(of: "https://", with: "")
                title = title.replacingOccurrences(of: ".com", with: "")
                title = title.prefix(1).uppercased() + title.dropFirst().lowercased()
                $0.title = title
                }.cellUpdate({[unowned self] (cell, _) in
                    cell.accessoryType = (self.defaultURLString == searchURL) ? .checkmark : .none
                }).onCellSelection({[weak self] (_, _) in
                    self?.defaultURLString = searchURL
                    if let switchRow = self?.form.rowBy(tag: SearchEngineTag) {
                        switchRow.section?.reload(with: .none)
                    }
                })
        }
    }
    func generateSections() -> [Section] {
        var section = Section()
        section <<< SwitchRow() {
                    $0.tag = SearchEngineTag
                    $0.title = L10n.Settings.Browser.Search.engine
                    $0.value = !self.isCustomURL
                }.onChange({[unowned self] (row) in
                    self.isCustomURL = !(row.value ?? true)
                    let nextRow = row.indexPath!.row + 1
                    let rows = self.isCustomURL == true ? self.inputURLRows() : self.searchEngineRows()
                    row.section?.replaceSubrange(nextRow..<row.section!.endIndex, with: rows)
                })
        if isCustomURL {
            section += self.inputURLRows()
        } else {
            section += self.searchEngineRows()
        }
        return [section]
    }

}
