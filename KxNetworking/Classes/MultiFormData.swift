//
//  MultiFormData.swift
//  KxNetworking
//
//  Created by Krishna Venkatramani on 09/12/2023.
//

import Foundation

public enum MultiFormData {
    case string(text: String, key: String)
    case image(img: Data, key: String, name: String)
}

public extension MultiFormData {
    
    func data(boundary: String) -> Data {
        var data = Data()
        switch self {
        case .string(let text, let key):
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(text)\r\n".data(using: .utf8)!)
        case .image(let imageData, let key, _):
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imageData)
            data.append("\r\n".data(using: .utf8)!)
        }
        return data
    }
    
}
