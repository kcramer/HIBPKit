//
//  URLs.swift
//  HIBPKit
//
//  Created by Kevin on 6/5/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

/**
 A configurable URL for a request to the HIBP service.  Given any required
 inputs, it will provide a URL to the service for the request.
 */
internal enum HIBPURL: CodableServiceURL {
    /// A request to get the occurrences of a password in reported breaches.
    case passwordsByRange(String)
    /// A request to get the breaches for a given domain.
    case breaches(String?)
    /// A request to get the breaches for a given account/email with a flag
    /// to specify if unverified breaches should be included.
    case breachesByAccount(String, Bool)
    /// A request to get the pastes for an email address.
    case pastesByAccount(String)

    /// The constructed URL for the request.
    public var url: URL? {
        let psswdBaseURL = "https://api.pwnedpasswords.com"
        let baseURL = "https://haveibeenpwned.com"
        switch self {
        case .passwordsByRange(let prefix):
            let comps = URLComponents(string: psswdBaseURL + "/range/")
            return comps?.url?.appendingPathComponent(prefix)
        case .breachesByAccount(let account, let unverified):
            var comps = URLComponents(string: baseURL + "/api/v2/breachedaccount/")
            if unverified {
                let item = URLQueryItem(name: "includeUnverified", value: "true")
                comps?.queryItems = [item]
            }
            return comps?.url?.appendingPathComponent(account)
        case .breaches(let domain):
            var comps = URLComponents(string: baseURL + "/api/v2/breaches/")
            if let domain = domain {
                let item = URLQueryItem(name: "domain", value: domain)
                comps?.queryItems = [item]
            }
            return comps?.url
        case .pastesByAccount(let email):
            let comps = URLComponents(
                string: baseURL + "/api/v2/pasteaccount/")
            return comps?.url?.appendingPathComponent(email)
        }
    }
}
