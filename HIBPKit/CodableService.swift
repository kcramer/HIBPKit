//
//  CodableService.swift
//  CodableService
//
//  Created by Kevin on 10/17/18.
//  Copyright © 2018 Kevin. All rights reserved.
//

import Foundation

/// An URL for a CodableService.  Generates an URL based on inputs.
internal protocol CodableServiceURL {
    /// An absolute URL for the request.
    var url: URL? { get }
}

/// Represents an active request that can be cancelled.
public protocol ServiceRequest {
    /// Cancel the request.
    func cancel()
}

/// A request for an URLSessionTask.
public struct NetworkServiceRequest: ServiceRequest {
    private var task: URLSessionTask?

    init(task: URLSessionTask?) {
        self.task = task
    }

    /// Cancel the request.
    public func cancel() {
        task?.cancel()
    }
}

/// The errors that can be returned from the requests.
public enum ServiceError: Error, Equatable {
    /// Not found.
    case notFound
    /// Invalid URL in request.
    case invalidURL
    /// Invalid response with error text.
    case invalidResponse(String)
    /// Error parsing the result.
    case parseError(String)
    /// Rate limit exceeded with retry in seconds and an error description.
    case rateLimitExceeded(Int?, String)
    /// Offline with no connectivity.
    case offline(String)
    /// General error retrieving the data.
    case error(String)
}

/// The decoder used to process results.
internal enum CodableDecoder {
    case json(JSONDecoder)
    case propertyList(PropertyListDecoder)
}

/// The signature of the function called to process the results of a fetch.
public typealias FetchCompletion = (Result<Data, ServiceError>) -> Void

/// The signature of the fuction that fetches the data from the service.
public typealias FetchFunction =
    (URL, String, @escaping FetchCompletion) -> ServiceRequest?

/**
 A generic service to handle simple services that return a result
 that can be processed by Codable.
 */
internal protocol CodableService {
    /// The decoder to use for the service.
    var decoder: CodableDecoder { get }

    /// The user agent to send to the service.
    var userAgent: String? { get }

    /// The URLSession to use for requests.
    var session: URLSession { get }

    /// Provide a configured URLSession for fetching the data.
    func getSession() -> URLSession

    /**
     Default function used to fetch the results from the service.
     - parameter url: The URL for the request.
     - parameter mimeType: The expected mime type.  If a different mime type
     is found, an error will be returned.
     - parameter completion: The completion handler to run when the request
     is completed.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    func fetch(url: URL,
               mimeType: String,
               completion: @escaping FetchCompletion) -> ServiceRequest?

    /**
     Process a single Codable result.
     - parameter data: The Data object to decode.
     - returns: The decoded object.
     */
    func process<T: Decodable>(data: Data) throws -> T

    /**
     Generic function to process requests that return JSON arrays.
     - parameter url: The URL used to make the request.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  This code
        is executed on the URLSession's dispatch queue so switch to the
        main thread if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    func processQuery<T: Decodable>(
        url urlObject: CodableServiceURL,
        mimeType: String,
        fetch: FetchFunction?,
        completion: @escaping (Result<T, ServiceError>) -> Void)
        -> ServiceRequest?
}

extension CodableService {
    /// A default JSONDecoder.
    var decoder: CodableDecoder {
        return .json(JSONDecoder())
    }

    /// Returns a session with a configured user agent.
    func getSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "User-Agent": self.userAgent as Any
            ].filter { $0.1 is String }
        return URLSession(configuration: config)
    }

    /**
     Default function used to fetch the results from the service.
     - parameter url: The URL for the request.
     - parameter mimeType: The expected mime type.  If a different mime type
        is found, an error will be returned.
     - parameter completion: The completion handler to run when the request
        is completed.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    func fetch(url: URL,
               mimeType: String,
               completion: @escaping FetchCompletion) -> ServiceRequest? {
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil, let response = response as? HTTPURLResponse else {
                if let urlError = error as? URLError, urlError.errorCode == -1009 {
                    completion(.failure(.offline("Error: \(String(describing: error))")))
                } else {
                    completion(.failure(.error("Error: \(String(describing: error))")))
                }
                return
            }

            guard response.statusCode != 404 else {
                completion(.failure(.notFound))
                return
            }

            guard response.statusCode != 429 else {
                let retryAfter = response.allHeaderFields["retry-after"] as? Int
                completion(.failure(.rateLimitExceeded(
                    retryAfter,
                    "Response: \(String(describing: response))")))
                return
            }

            guard error == nil,
                let mimeType = response.mimeType,
                mimeType == mimeType,
                let data = data else {
                    completion(.failure(.invalidResponse("""
                        Error: \(String(describing: error)), \
                        Response: \(String(describing: response))
                        """)))
                    return
            }
            completion(.success(data))
        }
        task.resume()
        return NetworkServiceRequest(task: task)
    }

    /**
     Process a single Codable result.
     - parameter data: The Data object to decode.
     - returns: The decoded object.
     */
    func process<T: Decodable>(data: Data) throws -> T {
        switch decoder {
        case .json(let decoder):
            return try decoder.decode(T.self, from: data)
        case .propertyList(let decoder):
            return try decoder.decode(T.self, from: data)
        }
    }

    /**
     Generic function to process requests that return JSON arrays.
     - parameter url: The URL used to make the request.
     - parameter fetch: An optional function to handle fetching the results.
     - parameter completion: The function to call with the results.  This code
        is executed on the URLSession's dispatch queue so switch to the
        main queue or another queue, if appropriate.
     - returns: A ServiceRequest that can be used to cancel the request.
     */
    func processQuery<T: Decodable>(
        url urlObject: CodableServiceURL,
        mimeType: String = "application/json",
        fetch: FetchFunction? = nil,
        completion: @escaping (Result<T, ServiceError>) -> Void)
        -> ServiceRequest? {
        guard let url = urlObject.url else {
            completion(.failure(.invalidURL))
            return nil
        }

        let fetchFunc = fetch ?? self.fetch
        return fetchFunc(url, mimeType) { result in
            switch result {
            case .success(let data):
                do {
                    let item: T = try self.process(data: data)
                    completion(.success(item))
                } catch {
                    completion(.failure(.parseError("Parse Error: \(error)")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
