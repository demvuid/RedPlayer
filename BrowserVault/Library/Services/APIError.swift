//
//  APIError.swift
//  Dating
//
//  Created by HaiLe on 11/20/18.
//  Copyright © 2018 Astraler. All rights reserved.
//

import Foundation

typealias APIErrored = (APIError) -> Void

enum APIError: Error {
    case error(Error)
    case jsonMapping
    case objectMapping(Error)
    case noData
    case notSecured
    case unknown    
}

// MARK: - Error Descriptions
extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .noData:
            return "No data"
        case .notSecured:
            return "Not security"
        case .unknown:
            return "Unknown"
        case .jsonMapping:
            return "Failed to map data to JSON."
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        }
    }
}

extension NSError {
    static var sslErrors: [Int] {
        return [NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateUntrusted, NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateNotYetValid, NSURLErrorServerCertificateHasUnknownRoot]
    }
}
