//
//  CollectionViewCellStyleTitleImage.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/7/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class CollectionViewCellStyleTitleImage: BaseCollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    var isEdit: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isEdit = false
        self.isSelected = false
    }
    
    override var isSelected: Bool {
        didSet{
            if self.isSelected && self.isEdit
            {
                self.imgView.alpha = 0.8
                self.tickImageView.isHidden = false
            }
            else
            {
                self.imgView.alpha = 1
                self.tickImageView.isHidden = true
            }
        }
    }


}
