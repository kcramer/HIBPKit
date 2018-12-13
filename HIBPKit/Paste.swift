//
//  Paste.swift
//  HIBPKit
//
//  Created by Kevin on 8/8/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

/// A Paste from the HIBP service.
public struct Paste: Codable, Equatable {
    /// The paste service where the paste was found.
    public let source: String
    /// A stable identifier for the record in the HIBP service.
    public let identifier: String
    /// The title found on the paste.  Optional, maybe not be present.
    public let title: String?
    /// The date the paste was posted on the paste service.  Optional.
    public let date: Date?
    /// THe number of email addresses in the paste.
    public let emailCount: Int

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case identifier = "Id"
        case title = "Title"
        case date = "Date"
        case emailCount = "EmailCount"
    }
}

/// A paste service where a particular paste was found.
public enum PasteService: String, RawRepresentable {
    case pastebin = "Pastebin"
    case pastie = "Pastie"
    case slexy = "Slexy"
    case ghostbin = "Ghostbin"
    case quickLeak = "QuickLeak"
    case justPaste = "JustPaste"
    case adHocUrl = "AdHocUrl"
    case optOut = "OptOut"

    /**
     Returns a constructed URL to a given paste service for the provided
     identifier.  Some types of paste service will not have an associated URL.
     */
    public func getURL(for identifier: String) -> String? {
        switch self {
        case .pastebin:
            return "https://pastebin.com/\(identifier)"
        case .pastie:
            return "https://pastiebin.org/\(identifier)"
        case .slexy:
            return "https://slexy.org/view/\(identifier)"
        case .ghostbin:
            return "https://ghostbin.com/paste/\(identifier)"
        case .justPaste:
            return "https://justpaste.it/\(identifier)"
        default:
            return nil
        }
    }
}
