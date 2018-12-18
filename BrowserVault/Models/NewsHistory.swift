//
//  NewsHistory.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/23/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

class NewsHistory: BaseModel {
    @objc dynamic var name = ""
    @objc dynamic var papeURL = ""
    @objc dynamic var isFavorites = false
    @objc dynamic var dateUpdated = Date()
    
    override class func primaryKey() -> String? {
        return "papeURL"
    }
}
