//
//  APIResource.swift
//  Dating
//
//  Created by HaiLe on 11/20/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

class APIResource: CustomStringConvertible {
    var description: String {
        return String(describing: raw!)
    }
    
    /// The response data.
    let data: Data
    
    /// The raw response data
    var raw: JSObject? {
        if _raw == nil {
            let jsonDict = try? self.mapJSON()
            _raw = jsonDict as? JSObject
        }
        return _raw
    }
    
    private var _raw: JSObject?
    
    required init(data: Data) {
        self.data = data
    }
    
    /// Maps data into a JSON object.
    ///
    /// - parameter failsOnEmptyData: A Boolean value determining
    /// whether the mapping should fail if the data is empty.
    func mapJSON(failsOnEmptyData: Bool = true) throws -> Any {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            if (data.count) < 1 && !failsOnEmptyData {
                return NSNull()
            }
            throw APIError.jsonMapping
        }
    }
    
    /// Maps data into a Decodable object.
    ///
    /// - parameter atKeyPath: Optional key path at which to parse object.
    /// - parameter using: A `JSONDecoder` instance which is used to decode data to an object.
    func map<D: Decodable>(to type: D.Type, atKeyPath keyPath: String? = nil, using decoder: JSONDecoder = JSONDecoder(), failsOnEmptyData: Bool = true) throws -> D {
        let serializeToData: (Any) throws -> Data? = { (jsonObject) in
            guard JSONSerialization.isValidJSONObject(jsonObject) else {
                return nil
            }
            do {
                return try JSONSerialization.data(withJSONObject: jsonObject)
            } catch {
                throw APIError.jsonMapping
            }
        }
        let jsonData: Data
        keyPathCheck: if let keyPath = keyPath {
            guard let jsonObject = (try mapJSON(failsOnEmptyData: failsOnEmptyData) as? NSDictionary)?.value(forKeyPath: keyPath) else {
                if failsOnEmptyData {
                    throw APIError.jsonMapping
                } else {
                    jsonData = data
                    break keyPathCheck
                }
            }
            
            if let data = try serializeToData(jsonObject) {
                jsonData = data
            } else {
                let wrappedJsonObject = ["value": jsonObject]
                let wrappedJsonData: Data
                if let data = try serializeToData(wrappedJsonObject) {
                    wrappedJsonData = data
                } else {
                    throw APIError.jsonMapping
                }
                do {
                    return try decoder.decode(DecodableWrapper<D>.self, from: wrappedJsonData).value
                } catch let error {
                    throw APIError.objectMapping(error)
                }
            }
        } else {
            jsonData = data
        }
        do {
            if jsonData.count < 1 && !failsOnEmptyData {
                if let emptyJSONObjectData = "{}".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONObjectData) {
                    return emptyDecodableValue
                } else if let emptyJSONArrayData = "[{}]".data(using: .utf8), let emptyDecodableValue = try? decoder.decode(D.self, from: emptyJSONArrayData) {
                    return emptyDecodableValue
                }
            }
            return try decoder.decode(D.self, from: jsonData)
        } catch let error {
            throw APIError.objectMapping(error)
        }
    }
}

private struct DecodableWrapper<T: Decodable>: Decodable {
    let value: T
}
