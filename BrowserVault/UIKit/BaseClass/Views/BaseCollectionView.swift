//
//  BaseCollectionView.swift
//  InternetBanking
//
//  Created by Hai Le on 7/12/16.
//  Copyright © 2016 Astraler Co., Ltd. All rights reserved.
//

import UIKit

class BaseCollectionView: UICollectionView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }

    func setupUI() {
        
    }
}
