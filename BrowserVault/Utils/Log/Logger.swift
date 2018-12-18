//
// Created by Nang Nguyen on 4/23/18.
// Copyright (c) 2018 Evizi. All rights reserved.
//

import Foundation
import CocoaLumberjack.Swift

/// Logger wrapper
@objc final public class Logger: NSObject {

    private static let sharedInstance = Logger()
    private let fileLogger = DDFileLogger()

    private override init() {
        #if DEBUG
            defaultDebugLevel = .all
        #else
            defaultDebugLevel = .info
        #endif

        let formatter = DDLogCustomFormatter()

        // TTY = XCode console
        if let ttyLogger = DDTTYLogger.sharedInstance {
            ttyLogger.logFormatter = formatter
            DDLog.add(ttyLogger, with: defaultDebugLevel)
        }

        // ASL = Apple System Log
        if let aslLogger = DDASLLogger.sharedInstance {
            aslLogger.logFormatter = formatter
            DDLog.add(aslLogger, with: defaultDebugLevel)
        }

        // Persistence log file that saves up to 2MB of logs to disk
        if let fileLogger = fileLogger {
            fileLogger.logFormatter = formatter
            fileLogger.rollingFrequency = 0 // no limits
            fileLogger.maximumFileSize = UInt64(1024 * 1024 * 2) // 2 MB
            fileLogger.logFileManager.maximumNumberOfLogFiles = 0
            fileLogger.logFileManager.logFilesDiskQuota = UInt64(1024 * 1024 * 2) // quota is 2 MB max
            DDLog.add(fileLogger, with: defaultDebugLevel)
        }
    }

    /// Log files
    ///
    /// - Returns: An array of DDLogFileInfo instances
    class func logFiles() -> [DDLogFileInfo] {
        return sharedInstance.fileLogger?.logFileManager.sortedLogFileInfos ?? []
    }

    // MARK: Private

    /// Log message constructor
    private func logMacro(message: String, flag: DDLogFlag, file: String, function: String, line: UInt) {
        let message = DDLogMessage(message: message,
            level: defaultDebugLevel,
            flag: flag,
            context: 0,
            file: file,
            function: function,
            line: line,
            tag: nil,
            options: [.copyFunction, .copyFile],
            timestamp: Date())

        // The default philosophy for asynchronous logging is very simple:
        // Log messages with errors should be executed synchronously.
        // All other log messages, such as debug output, are executed asynchronously.
        let trueForErrors = (flag == DDLogFlag.error) ? true : false

        DDLog.log(asynchronous: trueForErrors, message: message)
    }

    @objc public class func verbose(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        sharedInstance.logMacro(message: message, flag: .verbose, file: file, function: function, line: line)
    }

    @objc public class func debug(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        sharedInstance.logMacro(message: message, flag: .debug, file: file, function: function, line: line)
    }

    @objc public class func info(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        sharedInstance.logMacro(message: message, flag: .info, file: file, function: function, line: line)
    }

    @objc public class func warning(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        sharedInstance.logMacro(message: message, flag: .warning, file: file, function: function, line: line)
    }

    @objc public class func error(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        sharedInstance.logMacro(message: message, flag: .error, file: file, function: function, line: line)
    }
}
