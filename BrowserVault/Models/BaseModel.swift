//
//  BaseModel.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/6/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import RealmSwift

typealias BlockParseJsonModel = ([String: Any]) -> (BaseModel?, Error?)
typealias BlockParseJsonArrayModel = ([[String: Any]]) -> ([BaseModel]?, Error?)
public class BaseModel: Object {
}
