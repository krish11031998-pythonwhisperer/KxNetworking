//
//  URLSessionError.swift
//  KxNetworking
//
//  Created by Krishna Venkatramani on 09/12/2023.
//

import Foundation

public enum URLSessionError: String, Error {
    case noData
    case invalidResponse
    case invalidUrl
    case decodeErr
}

public enum URLSessionAdvanceError: Error {
    case dataDecoding(err: Error, url: String)
}

extension URLSessionAdvanceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataDecoding(let err, let url):
            return "(ERROR❗️) [🌐 \(url)] \(err.localizedDescription)"
        }
        
    }
}
