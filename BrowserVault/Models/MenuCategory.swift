//
//  MenuCategory.swift
//  Entertainment
//
//  Created by Hai Le on 8/21/16.
//  Copyright © 2016 GreenSol. All rights reserved.
//

import UIKit
import RealmSwift

class MenuCategories: BaseModel, Decodable {
    var categories = List<MenuCategory>()
    @objc dynamic var dateUpdated: Date! = Date()
    enum CodingKeys: String, CodingKey {
        case categories
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let items = try container.decode([MenuCategory].self, forKey: .categories)
            self.categories.append(objectsIn: items)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}

enum MenuCategoryType: Int, Decodable {
    case channel = 0
    case playlist = 1
    case user = 2
}

class MenuCategory: BaseModel, Decodable {
    @objc dynamic var categoryId: String = ""
    @objc dynamic var categoryType: Int = 0
    @objc dynamic var name: String = ""
    let items = List<YoutubeItem>()
    @objc dynamic var nextToken: String = ""
    @objc dynamic var dateUpdated: Date!
    
    enum CodingKeys: String, CodingKey {
        case categoryId
        case name
        case categoryType
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let categoryId = try container.decode(String.self, forKey: .categoryId)
            let name = try container.decode(String.self, forKey: .name)
            self.categoryId = categoryId
            self.name = name
            if let categoryType = try? container.decode(Int.self, forKey: .categoryType) {
                self.categoryType = categoryType
            }
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}
