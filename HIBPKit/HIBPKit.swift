//
//  SwiftHIBP.swift
//  SwiftHIBP
//
//  Created by Kevin on 4/4/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

/// A service that provides results from the Have I Been Pwned? database.
final public class HIBPService: CodableService {
    internal let userAgent: String?
    internal let apiKey: String?
    internal let baseURL: String?
    internal lazy var session: URLSession = {
        return getSession()
    }()

    /// A custom JSONDecoder with special date handling.
    internal var decoder: CodableDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = HIBPService.iso8601Custom
        return .json(decoder)
    }

    /**
     Create a HIBP Service.
     - parameter userAgent: The user agent to send to the service.  It
        identifies your app or service.  Required by the HIBP service.
     */
    public init(userAgent: String, apiKey: String? = nil, baseURL: String? = nil) {
        self.userAgent = userAgent
        self.apiKey = apiKey
        self.baseURL = baseURL
    }

    /// Returns a session with a configured user agent.
    func getSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": self.userAgent as Any,
            "Hibp-Api-Key": self.apiKey as Any
            ].filter { $0.1 is String }
        return URLSession(configuration: config)
    }

    /// Standard ISO8601 date formatter.
    private static let iso8601DateFormatter = ISO8601DateFormatter()
    /// A date formatter for simpler ISO8601 dates.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// A custom JSON date parser for the date format used by the service.
    public static let iso8601Custom: JSONDecoder.DateDecodingStrategy =
        .custom({ (decoder) -> Date in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)

        if let date = HIBPService.iso8601DateFormatter.date(from: dateStr) {
            return date
        }
        if let date = HIBPService.dateFormatter.date(from: dateStr) {
            return date
        }
        throw ServiceError.parseError("Error parsing '\(dateStr)'")
    })

    /// The result of a password request.
    public typealias PasswordResult = Result<Int, ServiceError>
    /// The result of a breach request.
    public typealias BreachResult = Result<[Breach], ServiceError>
    /// The result of a paste request.
    public typealias PasteResult = Result<[Paste], ServiceError>

    /// The signature of the completion function for a password request.
    public typealias PasswordCompletion = (PasswordResult) -> Void
    /// The signature of the completion function for a breach request.
    public typealias BreachCompletion = (BreachResult) -> Void
    /// The signature of the completion function for a paste request.
    public typealias PasteCompletion = (PasteResult) -> Void

    /**
     Verifies if a given string is a valid email for HIBP based on its format.
     Use this to verify if a string is an email before making a request for
     pastes.
     - parameter email: The string to check for validity as an email address.
     - returns: True if a valid email, false otherwise.
     */
    public static func isEmail(_ email: String) -> Bool {
        let emailRegEx = "(?!^.{256})[a-zA-Z0-9\\.\\-_\\+]+@[a-zA-Z0-9\\.\\-_]+\\.[a-zA-Z]+"
        return email.range(of: emailRegEx, options: .regularExpression) != nil
    }

    /**
     Check if the given password was found in a breach.  Data is returned via
     the callback.
     - parameter password: The password to search for.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  By default,
        this code is executed on the URLSession's dispatch queue so switch to the
        main queue or another queue, if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    @discardableResult
    public func passwordByRange(password: String,
                                fetch: FetchFunction? = nil,
                                completion: @escaping PasswordCompletion) -> ServiceRequest? {
        let expectedMimeType = "text/plain"
        guard let hash = Crypto.sha1(string: password) else { return nil }
        let prefix = hash.prefix(5)
        let suffix = hash.suffix(hash.count - 5).uppercased()

        let passwordURL = HIBPURL.passwordsByRange(String(prefix))
        guard let url = passwordURL.url else {
            completion(.failure(.invalidURL))
            return nil
        }

        let fetchFunc = fetch ?? self.fetch
        return fetchFunc(url, expectedMimeType) { result in
            switch result {
            case .failure(let error) where error == .notFound:
                completion(.success(0))
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let hashList = String(data: data, encoding: .ascii) else {
                    completion(.failure(.invalidResponse("Could not convert to string.")))
                    return
                }
                let counts = hashList
                    .split(separator: "\r\n")
                    .filter { $0.starts(with: suffix) }
                    .map { line -> Int in
                        let fields = line.split(separator: ":")
                        return Int(fields.last ?? "0") ?? 0
                }
                let count = counts.first ?? 0
                completion(.success(count))
            }
        }
    }

    /**
     Get all breaches or only for a given domain.  Data is returned via the callback.
     - parameter for: Optionally limit the breaches to this domain name.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  By default,
        this code is executed on the URLSession's dispatch queue so switch to the
        main queue or another queue, if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    @discardableResult
    public func allBreaches(for domain: String?,
                            fetch: FetchFunction? = nil,
                            completion: @escaping BreachCompletion) -> ServiceRequest? {
        return processQuery(url: HIBPURL.breaches(domain, baseURL),
                            fetch: fetch,
                            completion: completion)
    }

    /**
     Find the breaches for the given account.  Data is returned via the callback.
     - parameter for: The account name or email address to search for.
     - parameter unverified: Should unverified breaches be included in the results.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  By default,
        this code is executed on the URLSession's dispatch queue so switch to the
        main queue or another queue, if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    @discardableResult
    public func breaches(for account: String,
                         unverified: Bool = false,
                         fetch: FetchFunction? = nil,
                         completion: @escaping BreachCompletion) -> ServiceRequest? {
        return processQuery(
            url: HIBPURL.breachesByAccount(account, unverified, baseURL),
            fetch: fetch,
            completion: completion
        )
    }

    /**
     Find the pastes for the given email.  Data is returned via the callback.
     - parameter for: The email address to search for.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  By default,
        this code is executed on the URLSession's dispatch queue so switch to the
        main queue or another queue, if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    @discardableResult
    public func pastes(for email: String,
                       fetch: FetchFunction? = nil,
                       completion: @escaping PasteCompletion) -> ServiceRequest? {
        return processQuery(url: HIBPURL.pastesByAccount(email, baseURL),
                            fetch: fetch,
                            completion: completion)
    }
}
