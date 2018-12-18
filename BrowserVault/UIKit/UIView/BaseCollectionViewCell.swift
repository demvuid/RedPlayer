//
//  BaseCollectionViewCell.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/7/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Reusable

class BaseCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetUI()
    }

    override func prepareForReuse() {
        self.resetUI()
    }
    
    func resetUI() {
        
    }
}
