//
//  BaseCollectionViewCell.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/7/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import Reusable

class MenuItem {
    var name: String!
    var iconName: String!
    var iconUrl: String!
    
    init(name: String!, iconName: String!, iconUrl: String!) {
        self.name = name
        self.iconName = iconName
        self.iconUrl = iconUrl
    }
    
    
}

class BaseCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        brandingUI()
        resetUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        brandingUI()
    }
    
    override func prepareForReuse() {
        self.resetUI()
    }
    
    func resetUI() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func brandingUI() {
        
    }
    
    func setupUI() {
        
    }
    
    func configData(_ item: MenuItem) {
        if self.title != nil {
            if let name = item.name {
                self.title.text = name
            }
        }
        
        if self.icon != nil {
            if let iconName = item.iconName {
                self.icon.image = UIImage(named: iconName)
            } else if let iconUrl = item.iconUrl, let url = URL(string: iconUrl) {
                ImageFetcher.fetchImage(from: url, to: self.icon)
            }
        }
    }
}
