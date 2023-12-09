//
//  DataCache.swift
//  KxNetworking
//
//  Created by Krishna Venkatramani on 09/12/2023.
//

import Foundation


// MARK: - CacheSubscript

internal protocol CacheSubscript {
    subscript(_ request: URLRequest) -> Data? { get }
}


// MARK: - DataCache

internal struct DataCache {
    static var shared: DataCache = .init()
    
    var cache: NSCache<NSURLRequest,NSData> = {
        let cache = NSCache<NSURLRequest,NSData>()
        cache.totalCostLimit = 300_000_000
        return cache
    }()
}

extension DataCache: CacheSubscript {
    subscript(request: URLRequest) -> Data? {
        get {
            return cache.object(forKey: request as NSURLRequest) as? Data
        }
        
        set {
            guard let validData = newValue as? NSData else { return }
            cache.setObject(validData, forKey: request as NSURLRequest)
        }
    }
}
