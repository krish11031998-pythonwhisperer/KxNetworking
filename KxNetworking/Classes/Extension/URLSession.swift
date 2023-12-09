//
//  URLSession.swift
//  KxNetworking
//
//  Created by Krishna Venkatramani on 09/12/2023.
//

import Foundation
import Combine

public extension URLSession {

     static func urlSessionRequest<T: Codable>(request: URLRequest, refresh: Bool) -> Future<T,Error> {
        Future { promise in
            print("(REQUEST🚀) Request: \(request.url?.absoluteString ?? "")")
            if let method = request.httpMethod {
                print("(REQUEST🚀) Request-Method: \(method)")
            }
            if let body = request.httpBody {
                print("(REQUEST🚀) Request-Body: \(String(describing: String(data: body, encoding: .utf8)))")
            }
            if let cachedData = DataCache.shared[request], !refresh {
                if let deceodedData = try? JSONDecoder().decode(T.self, from: cachedData) {
                    print("(REQUEST📩) returning Cached Response for : \(request.url?.absoluteString ?? "")")
                    promise(.success(deceodedData))
                } else {
                    promise(.failure(URLSessionError.decodeErr))
                }
            } else {
                let session = URLSession.shared.dataTask(with: request) { data, resp , err in
                    guard let validData = data, let _ = resp else {
                        promise(.failure(err ?? URLSessionError.noData))
                        return
                    }
                    
                    do {
                        let decodedData = try JSONDecoder().decode(T.self, from: validData)
                        DataCache.shared[request] = validData
                        print("(REQUEST📩) returning Received Response for : \(request.url?.absoluteString ?? "")")
                        promise(.success(decodedData))
                    } catch {
                        let decodeErr = err ?? URLSessionError.decodeErr
                        promise(.failure(URLSessionAdvanceError.dataDecoding(err: decodeErr, url: request.url?.absoluteString ?? "")))
                    }
                }
                session.resume()
            }
        }
    }
        
    static func urlUploadTask<T: Codable>(request: URLRequest, data: Data) -> Future<T,Error> {
        return Future { promise in
            print("(REQUEST🚀) Request: \(request.url?.absoluteString ?? "")")
            let uploader = URLSession.shared.uploadTask(with: request, from: data) { data, resp, err in
                
                guard let validResponse = resp as? HTTPURLResponse,
                      200..<300 ~= validResponse.statusCode
                else {
                    promise(.failure(URLSessionError.invalidResponse))
                    return
                }
                
                guard let validData = data else {
                    promise(.failure(err ?? URLSessionError.noData))
                    return
                }
                
                
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: validData)
                    print("(REQUEST📩) returning Received Response for : \(request.url?.absoluteString ?? "")")
                    promise(.success(decodedData))
                } catch {
                    promise(.failure(err ?? URLSessionError.decodeErr))
                }
            }
            uploader.resume()
        }
    }
}
