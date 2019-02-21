//
//  YoutubeChannel.swift
//  Entertainment
//
//  Created by Hai Le on 6/26/17.
//  Copyright © 2017 GreenSol. All rights reserved.
//

import UIKit
import RealmSwift

class YoutubeChannel: BaseModel, Decodable {
    @objc dynamic var channelId: String = ""
    @objc dynamic var playlistId: String = ""
    
    enum CodingKeys: String, CodingKey {
        case channelId = "id"
        case contentDetails
        case playlists = "relatedPlaylists.uploads"
    }
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let channelId = try? container.decodeIfPresent(String.self, forKey: .channelId) {
            self.channelId = channelId ?? ""
        }
        if let contentDetails = try? container.decodeIfPresent([String: Any].self, forKey: .contentDetails) {
            if let playlistId = (contentDetails as NSDictionary?)?.value(forKeyPath: CodingKeys.playlists.rawValue) as? String {
                self.playlistId = playlistId
            }
        }
    }
}

class YoutubeChannels: BaseModel, Decodable {
    var channels = List<YoutubeChannel>()
    
    enum CodingKeys: String, CodingKey {
        case channels = "items"
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let items = try container.decode([YoutubeChannel].self, forKey: .channels)
        self.init()
        self.channels.append(objectsIn: items)
    }
}
