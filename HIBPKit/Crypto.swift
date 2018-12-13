//
//  Crypto.swift
//  HIBPKit
//
//  Created by Kevin on 6/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation
import CommonCrypto

// Provides convenience methods for generating a SHA1 value.
enum Crypto {
    /// Return the SHA1 hash of a Data object.
    static func sha1(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA1(bytes, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }

    /// Return the SHA1 hash of a string as a hexadecimal string.
    static func sha1(string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }
        let hash = sha1(data: data)
        let hashString = hash.map { (byte) -> String in
            return String(format: "%02x", byte)
            }.joined()
        return hashString
    }
}
