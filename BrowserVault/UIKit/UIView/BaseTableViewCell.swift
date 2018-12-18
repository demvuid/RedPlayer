//
//  BaseTableViewCell.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/16/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Reusable

class BaseTableViewCell: UITableViewCell, Reusable, NibLoadable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
