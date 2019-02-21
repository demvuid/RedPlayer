//
//  BaseMenuItemCell.swift
//  Entertainment
//
//  Created by Hai Le on 8/7/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit

class BaseMenuItemCell: BaseCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        self.title.font = AppBranding.UITableViewCellFont.titleLabel.font
    }
    
    override func configData(_ item: MenuItem) {
        super.configData(item)
    }
}
