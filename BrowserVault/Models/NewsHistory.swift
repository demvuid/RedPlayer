//
//  NewsHistory.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/23/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit
import RealmSwift

class NewsHistory: Object {
    @objc dynamic var pageURL: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var isFavorites = false
    @objc dynamic var dateUpdated = Date()
    
    override static func primaryKey() -> String? {
        return "pageURL"
    }
}
