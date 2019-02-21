//
//  GroupYoutube.swift
//  Entertainment
//
//  Created by Hai Le on 6/23/17.
//  Copyright © 2017 GreenSol. All rights reserved.
//

import UIKit
import RealmSwift

class GroupYoutube: BaseModel, Decodable {
    @objc dynamic var groupId: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var icon: String = ""
    var categories = List<MenuCategory>()
    
    enum CodingKeys: String, CodingKey {
        case groupId = "group_id"
        case name
        case icon
        case categories
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let groupId = try container.decode(String.self, forKey: .groupId)
            let name = try container.decode(String.self, forKey: .name)
            let items = try container.decode([MenuCategory].self, forKey: .categories)
            let icon = try container.decode(String.self, forKey: .icon)
            self.groupId = groupId
            self.name = name
            self.icon = icon
            self.categories.append(objectsIn: items)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
        
    }
}

class MenuGroup: BaseModel, Decodable {
    var groups = List<GroupYoutube>()
    @objc dynamic var dateUpdated: Date! = Date()
    enum CodingKeys: String, CodingKey {
        case groups = "menu_group"
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([GroupYoutube].self, forKey: .groups)
        self.init()
        self.groups.append(objectsIn: items)
    }
}
