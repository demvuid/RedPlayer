//
//  TableViewCellStyleTitleImage.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/16/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class TableViewCellStyleTitleImage: BaseTableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
