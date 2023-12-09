import Foundation
import Combine


// MARK: - Endpoint

public protocol EndPoint {
    var scheme: String { get }
    var baseUrl: String { get }
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
    var body: Data? { get }
    var request: URLRequest? { get }
    var header: [String : String]? { get }
    func execute<CodableModel: Codable>(refresh: Bool) -> Future<CodableModel,Error>
    func amendRequestForMultiformDataUpload(keyValues: [MultiFormData]) -> (URLRequest?, Data?)
    func upload<CodableModel: Codable>(dataValues: [MultiFormData]) -> Future<CodableModel, Error>
}


// MARK: - Default Implementation of Endpoint Protocol

public extension EndPoint {
    
    var scheme: String {
        return "https"
    }
    
    var method: String {
        return "GET"
    }
    
    var header: [String : String]? {
        return nil
    }
    
    var body: Data? {
        nil
    }
    
    var request: URLRequest? {
        var uC = URLComponents()
        uC.scheme = scheme
        uC.host = baseUrl
        uC.path = path
        uC.queryItems = queryItems.emptyOrNil
        
        guard let url = uC.url  else {
            return nil
        }
        
        var request: URLRequest = .init(url: url)
        request.allHTTPHeaderFields = header
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method
        return request
    }
    
    func amendRequestForMultiformDataUpload(keyValues: [MultiFormData]) -> (URLRequest?, Data?) {
        let boundary = "Boundary-\(UUID().uuidString)"
        guard var newRequest = self.request else { return (nil, nil) }
        newRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        keyValues.forEach {
            data.append($0.data(boundary: boundary))
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return (newRequest, data)
    }
    
    func execute<CodableModel: Codable>(refresh: Bool = false) -> Future<CodableModel, Error> {
        guard let validRequest = request else {
            return Future { $0(.failure(URLSessionError.invalidUrl))}
        }
        return URLSession.urlSessionRequest(request: validRequest, refresh: refresh)
    }
    
    func upload<CodableModel: Codable>(dataValues: [MultiFormData]) -> Future<CodableModel, Error> {
        let (request, data) = amendRequestForMultiformDataUpload(keyValues: dataValues)
        guard let validRequest = request, let data = data else {
            return Future { $0(.failure(URLSessionError.invalidUrl))}
        }
        return URLSession.urlUploadTask(request: validRequest, data: data)
    }
}

