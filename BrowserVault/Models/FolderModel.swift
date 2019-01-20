//
//  FolderModel.swift
//  BrowserVault
//
//  Created by HaiLe on 12/16/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import RealmSwift

public class FolderModel: BaseModel {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var enablePasscode = false
    @objc dynamic var lastPathImage: String? = nil
    @objc dynamic var isLibrary = false
    let medias = LinkingObjects(fromType: Media.self, property: "folder")
    
    var url: String? = nil
    var image: UIImage!
    
    override public class func primaryKey() -> String? {
        return "id"
    }
    
    override public class func ignoredProperties() -> [String] {
        return ["image", "url"]
    }
}

extension FolderModel {
    var folderURL: URL {
        let folderURL = documentURL.appendingPathComponent(name)
        if !fileManger.fileExists(atPath: folderURL.path) {
            try! fileManger.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
        }
        return folderURL
    }
    
    var imageURL: URL? {
        if let lastPathImage = lastPathImage {
            return folderURL.appendingPathComponent(lastPathImage)
        }
        return nil
    }
}
