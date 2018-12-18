//
//  FilesFormView.swift
//  BrowserVault
//
//  Created by HaiLe on 12/18/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import Eureka

class FilesFormView: BaseFormViewController {
    private var folders = [FolderModel]()
    
    convenience init(folders: [FolderModel]) {
        self.init(nibName: nil, bundle: nil)
        self.folders.append(contentsOf: folders)
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
        var rows = [BaseRow]()
        for folder in folders {
            rows.append(LabelRow() {
                $0.title = folder.name
                if let imageURL = folder.imageURL, let image = UIImage(contentsOfFile: imageURL.path)?.resizeTo(newSize: CGSize(width: 60, height: 50)) {
                    $0.baseCell.imageView?.image = image
                    
                } else {
                    $0.baseCell.imageView?.image = Asset.Folder.folder.image
                }
                $0.baseCell.height = { 60 }
                }.cellUpdate({ (cell, _) in
                    cell.accessoryType = .disclosureIndicator
                }))
        }
        return rows
    }
}
