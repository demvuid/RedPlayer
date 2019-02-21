//
//  Suggestion.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

class Suggestion: BaseModel, Decodable {
    @objc dynamic var type: String = ""
    @objc dynamic var suggestion: String = ""
    
    enum CodingKeys: String, CodingKey {
        case type
        case suggestion
    }
    
    convenience init(type: String?, suggestion: String?) {
        self.init()
        self.type = type ?? ""
        self.suggestion = suggestion ?? ""
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(String.self, forKey: .type)
        let suggestion = try? container.decode(String.self, forKey: .suggestion)
        self.init(type: type, suggestion: suggestion)
    }
}
