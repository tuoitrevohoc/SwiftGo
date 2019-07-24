//
//  BsonSize.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-23.
//

import Foundation

/// Size of common bson data type
struct BsonSize {
    static let stringBoundary = 5
    static let doubleSize = 8
    static let booleanSize = 1
    static let objectIdSize = 12
    static let dateSize = 8
    static let int64Size = 8
    static let int32Size = 4
    static let decimal128Size = 16
}
