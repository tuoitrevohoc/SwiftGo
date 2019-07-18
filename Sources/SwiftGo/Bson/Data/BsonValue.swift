//
//  BsonValue.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

/// Bson value
enum BsonValue {
    case double(Double)
    case string(String)
    case document(BsonDocument)
    case array(BsonDocument)
    case binary([UInt8], type: BinarySubType)
    case objectId([UInt8])
    case boolean(Bool)
    case null
    case regExp(String, scope: String)
    case code(String)
    case code(String, scope: BsonDocument)
    case int32(Int32)
    case timestamp(UInt64)
    case int64(Int64)
    case decimal128([UInt8])
    case minKey
    case maxKey
}
