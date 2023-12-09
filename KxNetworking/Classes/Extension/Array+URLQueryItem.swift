//
//  Array+Extension.swift
//  KxNetworking
//
//  Created by Krishna Venkatramani on 09/12/2023.
//

import Foundation

public extension Array {
    
    var emptyOrNil: [Self.Element]? {
        isEmpty ? nil : self
    }
}

public extension Array where Self.Element == URLQueryItem {
    
    func filtered() -> [URLQueryItem] {
        self.filter { $0.value != nil && $0.value != "" }
    }
}
