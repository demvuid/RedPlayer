//
//  BaseCollectionReusableView.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/7/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import Reusable

class BaseCollectionReusableView: UICollectionReusableView, Reusable, NibLoadable {
    @IBOutlet weak var titleLabel: UILabel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetViewData()
    }
    
    override func prepareForReuse() {
        self.resetViewData()
    }
    
    
    func resetViewData() {
        self.titleLabel?.font = AppBranding.baseFont
    }
}
