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
    case breaches(String?, String?)
    /// A request to get the breaches for a given account/email with a flag
    /// to specify if unverified breaches should be included.
    case breachesByAccount(String, Bool, String?)
    /// A request to get the pastes for an email address.
    case pastesByAccount(String, String?)

    /// The constructed URL for the request.
    public var url: URL? {
        let psswdBaseURL = "https://api.pwnedpasswords.com"
        let apiBaseURL = "https://haveibeenpwned.com"
        switch self {
        case .passwordsByRange(let prefix):
            let comps = URLComponents(string: psswdBaseURL + "/range/")
            return comps?.url?.appendingPathComponent(prefix)
        case .breachesByAccount(let account, let unverified, let baseURL):
            let baseURL = baseURL ?? apiBaseURL
            var comps = URLComponents(string: baseURL + "/api/v3/breachedaccount/")
            let truncate = URLQueryItem(name: "truncateResponse", value: "false")
            comps?.queryItems = [truncate]
            if !unverified {
                let item = URLQueryItem(name: "includeUnverified", value: "false")
                comps?.queryItems = [truncate, item]
            }
            return comps?.url?.appendingPathComponent(account)
        case .breaches(let domain, let baseURL):
            let baseURL = baseURL ?? apiBaseURL
            var comps = URLComponents(string: baseURL + "/api/v3/breaches/")
            if let domain = domain {
                let item = URLQueryItem(name: "domain", value: domain)
                comps?.queryItems = [item]
            }
            return comps?.url
        case .pastesByAccount(let email, let baseURL):
            let baseURL = baseURL ?? apiBaseURL
            let comps = URLComponents(
                string: baseURL + "/api/v3/pasteaccount/")
            return comps?.url?.appendingPathComponent(email)
        }
    }
}
