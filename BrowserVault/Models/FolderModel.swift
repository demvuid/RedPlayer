//
//  FolderModel.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import RealmSwift

class FolderModel: BaseModel {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var enablePasscode = false
    @objc dynamic var url: String? = nil
    var image: UIImage!
    @objc dynamic var lastPathImage: String? = nil
    
    var imageURL: URL? {
        if let lastPathImage = lastPathImage, let url = URL(string: "\(documentPathURL.absoluteString)\(lastPathImage)") {
            return url
        }
        return nil
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func ignoredProperties() -> [String] {
        return ["image", "url"]
    }
}
