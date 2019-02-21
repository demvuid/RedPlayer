//
//  RealmSwift.swift
//  VideoPlayer
//
//  Created by Hai Le on 2/26/18.
//  Copyright © 2018 Evizi. All rights reserved.
//

import RealmSwift

struct RealmConstants {
    static let realmFolder = "RealmSwift"
    static let realmDB = "BrowserVault"
}

var realmURL: URL {
    let lastPath = RealmConstants.realmFolder
    let realmPath = documentURL.path + "/\(lastPath)"
    if !fileManger.fileExists(atPath: realmPath) {
        try! fileManger.createDirectory(atPath: realmPath, withIntermediateDirectories: true, attributes: nil)
    }
    return documentURL.appendingPathComponent(lastPath)
}

var realm: Realm! {
    var realm: Realm!
    do {
        let objectTypes = [NewsHistory.self, FolderModel.self, Media.self,
                           MenuCategories.self, MenuCategory.self, GroupYoutube.self,
                           MenuGroup.self, YoutubeChannel.self, YoutubeChannels.self,
                           YoutubeItem.self, PageInfo.self, YouTubeResult.self]
        var config = Realm.Configuration(fileURL: realmURL.appendingPathComponent("\(RealmConstants.realmDB).realm"), objectTypes: objectTypes)
        config.deleteRealmIfMigrationNeeded = true
        realm = try Realm(configuration: config)
    } catch {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent(RealmConstants.realmFolder).appendingPathComponent("\(RealmConstants.realmDB).realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()

    }
    return realm
}

extension Realm {
    func commitWriting() {
        do {
            try commitWrite()
        } catch {
            
        }
    }
}
