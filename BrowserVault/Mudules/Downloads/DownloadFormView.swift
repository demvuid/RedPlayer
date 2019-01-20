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

private let URLRowTag = "URLRowTag"
class DownloadFormView: BaseFormViewController {
    var observableURL: AnyObserver<URL?>!
    private var browseType: BrowseFileType = .download
    convenience init(displayData: DownloadDisplayData) {
        self.init(nibName: nil, bundle: nil)
        self.browseType = displayData.browseType
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupFormView() {
        form = Form()
        +++ self.inputURLSection()
    }
    
    func inputURLSection() -> Section {
        var section = Section()
        var rows = [BaseRow]()
        rows.append(URLRow() {
            $0.add(rule: RuleURL())
            $0.tag = URLRowTag
            $0.cellStyle = .subtitle
            $0.title = L10n.Downloads.Url.network
            $0.placeholder = L10n.Downloads.Url.place
            $0.baseCell.height = { 70 }
            }
        )
        rows.append(ButtonRow() {
            $0.title = self.browseType == .download ? L10n.Downloads.File.download : L10n.Downloads.File.play
            }.cellUpdate({ (cell, _) in
                cell.backgroundColor = ColorName.mainColor
                cell.textLabel?.textColor = ColorName.whiteColor
            }).onCellSelection({[weak self] (_, _) in
                if let urlRow = self?.form.rowBy(tag: URLRowTag) as? URLRow {
                    self?.observableURL?.onNext(urlRow.value)
                }
            })
        )
        section += rows
        return section
    }

}
