//
//  Breach.swift
//  HIBPKit
//
//  Created by Kevin on 6/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

/// A breach from the HIBP service.
public struct Breach: Codable, Equatable {
    /// The descriptive title for the breach.
    public let title: String
    ///  A stable idenfitier for the breach in the HIBP service.
    public let name: String
    /// The domain of the affected site.
    public let domain: String
    /**
     The date the breach occurred.  May not be accurate as a breach may be
     reported later and not when it occurred.
     */
    public let breachDate: Date
    /// The date the breach was added to HIBP database.
    public let addedDate: Date
    /// The date the breach was last modified in the HIBP database.
    public let modifiedDate: Date
    /// The number of accounts affected in the breach.
    public let pwnCount: Int
    /// A description of the breach in HTML markup.
    public let descriptionText: String
    /// The classes of data included in the breach.
    public let dataClasses: [String]
    /**
     Is the breach verified.  Unverified indicates the data may not be from
     the indicated site.  A breach is added as unverified if there is strong
     confidence that most of the data is legitimate.
     */
    public let isVerified: Bool
    /**
     Is the breach fabricated.  The data of a fabricated breach does not come
     from the indicated website.  It still contains legitimate email addresses
     and asserts that the account owners were compromised in the alleged breach.
     */
    public let isFabricated: Bool
    /**
     Is the breach sensitive?  Sensitive breaches are not returned by the
     HIBP service.
     */
    public let isSensitive: Bool
    /// Is it retired?  Retired breaches are not returned by the service.
    public let isRetired: Bool
    /**
     Is it a spam list?  A spam list is not an actual security breach but still
     contains personal information.
     */
    public let isSpamList: Bool
    /// The URL path to the logo image for the breach.
    public let logoPath: String?

    /// Returns an URL for logo.
    public var logoURL: URL? {
        guard let path = logoPath, !path.isEmpty else { return nil }
        return URL(string: path)
    }

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case name = "Name"
        case domain = "Domain"
        case breachDate = "BreachDate"
        case addedDate = "AddedDate"
        case modifiedDate = "ModifiedDate"
        case pwnCount = "PwnCount"
        case descriptionText = "Description"
        case dataClasses = "DataClasses"
        case isVerified = "IsVerified"
        case isFabricated = "IsFabricated"
        case isSensitive = "IsSensitive"
        case isRetired = "IsRetired"
        case isSpamList = "IsSpamList"
        case logoPath = "LogoPath"
    }
}
