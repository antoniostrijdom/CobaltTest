//
//  WebServiceMethod.swift
//  CobaltTest
//
//  Created by Antonio Strijdom on 11/04/2018.
//  Copyright © 2018 Antonio Strijdom. All rights reserved.
//

import Foundation
import CryptoSwift

// MARK: - Error

/// WebServiceMethodError error type
///
/// - InvalidURLError: the url generated for the request is somehow invalid
/// - CommsError: could not communicate with the service
/// - HTTPError: an unexpected HTTP result code was returned
/// - NoDataError: no data was returned
/// - ParseError: data could not be parsed
enum WebServiceMethodError: Error {
    case InvalidURLError
    case CommsError
    case HTTPError(code: Int)
    case NoDataError
    case ParseError
}

// MARK: - Protocol

/// protocol that defines generic web method calls
protocol WebServiceMethod {
    associatedtype Response: Decodable
    var requestURL: URL { get }
    var httpHeaders: [(String, String)]? { get }
    var defaultParameters: [URLQueryItem]? { get }
}

extension WebServiceMethod {
    /// Sends a synchronous blocking request to the server and returns the response
    /// - Returns: A tuple of the HTTP response and the deserialised body data
    /// - Throws: 
    ///   - `InvalidURLError` - the url called was invalid.
    ///   - `CommsError` - the server could not be reached.
    ///   - `HTTPError` - an HTTP result code other than 200 was received.
    ///   - `NoDataError` - no data was returned.
    ///   - `ParseError` - tge result could not be parsed
    func sendRequestSync(parameters: [URLQueryItem]?) throws -> (HTTPURLResponse, Response?) {
        // build the url
        guard var components = URLComponents(url: requestURL,
                                             resolvingAgainstBaseURL: false) else {
            throw WebServiceMethodError.InvalidURLError
        }
        // add query items
        components.queryItems = (defaultParameters ?? []) + (parameters ?? [])
        // make sure the final url is valid
        guard let finalURL = components.url else {
            throw WebServiceMethodError.InvalidURLError
        }
        // build the request
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        // add headers
        if let headers = httpHeaders {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        // send the request
        var response: URLResponse? = nil
        var data: Data? = nil
        var error: Error? = nil
        // use a semaphore to block while waiting for a response
        let semaphore = DispatchSemaphore.init(value: 0)
        // initiate the data task
        URLSession.shared.dataTask(with: request, completionHandler: { (taskData, taskResponse, taskError) in
            data = taskData
            response = taskResponse
            error = taskError
            semaphore.signal()
        }).resume()
        semaphore.wait()
        // error checking
        guard let responseData = data else {
            throw WebServiceMethodError.NoDataError
        }
        guard nil != response else {
            throw WebServiceMethodError.CommsError
        }
        guard nil == error else {
            throw error!
        }
        // cast URLResponse to HTTPURLResponse
        if let httpResponse = response as? HTTPURLResponse {
            // expecting a 200...
            if 200 == httpResponse.statusCode {
                do {
                    // deserialize the response into the Response type
                    let result = try JSONDecoder().decode(Response.self,
                                                          from: responseData)
                    return (httpResponse, result)
                } catch {
                    throw WebServiceMethodError.ParseError
                }
            } else {
                throw WebServiceMethodError.HTTPError(code: httpResponse.statusCode)
            }
        } else {
            // assume a 500
            throw WebServiceMethodError.HTTPError(code: 500)
        }
    }
}
