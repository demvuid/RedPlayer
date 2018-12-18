//
//  CustomError.swift
//  BrowserVault
//
//  Created by HaiLe on 12/11/18.
//  Copyright © 2018 GreenSolution. All rights reserved.
//

import UIKit

enum CustomError: Error {
    case error(Error)
    case unknown
    case message(String)
}

// MARK: - Error Descriptions
extension CustomError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let error):
            return error.localizedDescription
        case .unknown:
            return "Unknown"
        case .message(let message):
            return message
        }
    }
}
