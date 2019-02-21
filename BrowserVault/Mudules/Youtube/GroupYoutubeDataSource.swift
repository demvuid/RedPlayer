//
//  GroupYoutubeDataSource.swift
//  TopSongs
//
//  Created by Hai Le on 4/22/17.
//  Copyright © 2017 SmartGreenSolution. All rights reserved.
//

import UIKit

class GroupYoutubeDataSource: NSObject {
    weak var delegate: YoutubeViewInterface!
    func configCell(_ cell: BaseTableViewCell, indexPath: IndexPath) {
        cell.selectionStyle = .none
        if let items = self.delegate?.listGroupYoutube() {
            let item = items[indexPath.row]
            cell.titleLabel.text = item.name
            cell.accessoryType = .none
            if let currentItem = self.delegate?.currentGroupYoutube() {
                if currentItem.name == item.name {
                    cell.accessoryType = .checkmark
                }
            }
        }
    }
    
}

extension GroupYoutubeDataSource: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = self.delegate?.listGroupYoutube() {
            return items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BaseTableViewCellStyle.basic.rawValue) as! BaseTableViewCell
        self.configCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let items = self.delegate?.listGroupYoutube() {
            let item = items[indexPath.row]
            if self.delegate != nil {
                self.delegate.selectGroupYoutube(item)
            }
        }
    }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

