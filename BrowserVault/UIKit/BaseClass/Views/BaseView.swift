//
//  BaseView.swift
//  5sOnlineOffice
//
//  Created by Hai Le on 7/8/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit

class BaseView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        brandingUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        brandingUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func brandingUI() {
        
    }
    
    func setupUI() {
        
    }

}
