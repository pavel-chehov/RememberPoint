//
//  TextLog.swift
//  RememberPoint
//
//  Created by Pavel Chehov on 10/01/2019.
//  Copyright © 2019 Pavel Chehov. All rights reserved.
//

import Foundation
import os

final class Log {
    static let instance = Log()
    private let general = OSLog(subsystem: "com.app.RememberPoint", category: "general")
    private init() {}

    private lazy var fileName: URL = {
        let url = try! FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("log.txt")
        return url
    }()

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        let time = formatter.string(from: Date())
        return time
    }

    func write(_ string: String) {
        #if RELEASE
            return
        #endif

        let logString = "\(timeString) \(string)\n"
        os_log("%@", log: general, type: .info, logString)
        if !FileManager.default.fileExists(atPath: fileName.path) {
            FileManager.default.createFile(atPath: fileName.path, contents: nil, attributes: nil)
        }
        let file = FileHandle(forWritingAtPath: fileName.path)!
        file.seekToEndOfFile()
        file.write(logString.data(using: .utf8)!)
        file.closeFile()
    }
}
