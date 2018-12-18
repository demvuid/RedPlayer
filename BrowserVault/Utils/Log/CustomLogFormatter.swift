//
// Created by Nang Nguyen on 4/23/18.
// Copyright (c) 2018 Evizi. All rights reserved.
//

import Foundation
import CocoaLumberjack.Swift

class DDLogCustomFormatter: NSObject, DDLogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        // Log format as below: [ISO8601Z DateTime] <Class Name> VERBOSE/DEBUG/INFO/WARN/ERROR: Log Message
        return NSString(format: "[%@] <%@> [%@]: %@", logMessage.timestamp.iso8601, logMessage.fileName, logMessage.flag.toString(), logMessage.message) as String
    }
}

extension DDLogFlag {
    
    func toString() -> String {
        switch self {
        case DDLogFlag.error:
            return "ERROR"
        case DDLogFlag.warning:
            return "WARN"
        case DDLogFlag.info:
            return "INFO"
        case DDLogFlag.debug:
            return "DEBUG"
        case DDLogFlag.verbose:
            return "VERBOSE"
        default:
            return "UNKNOWN"
        }
    }
}

/// ISO8601Z Date Formatter
extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}
