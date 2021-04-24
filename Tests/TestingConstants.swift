//
//  TestingConstants.swift
//  HIBPKit
//
//  Created by Kevin on 8/22/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

enum TestingConstants {
    static let userAgent = "HIBPKit-Swift-Library"
    static let apiKey = environmentVariable(name: "HIBP_API_KEY")
    static let baseURL = environmentVariable(name: "HIBP_BASE_URL")

    static func environmentVariable(name: String) -> String? {
        return ProcessInfo.processInfo.environment[name]
    }
}
