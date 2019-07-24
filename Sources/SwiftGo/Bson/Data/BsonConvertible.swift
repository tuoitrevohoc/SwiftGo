//
//  BsonConvertible.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-23.
//

import Foundation

/// Bson Convertible
public protocol BsonConvertible {
    
    /// Convert to BsonValue
    func toBsonValue() -> BsonValue
}
