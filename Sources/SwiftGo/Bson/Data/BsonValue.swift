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
    case date(Date)
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

/// the bson value extension
extension BsonValue {
    
    /// Map to bson value type
    var type: BsonValueType {
        switch self {
        case .double:
            return .double
        case .string:
            return .string
        case .document:
            return .document
        case .array:
            return .array
        case .binary:
            return .binary
        case .code(_, scope: _):
            return .codeWithScope
        case .objectId:
            return .objectId
        case .boolean:
            return .boolean
        case .date:
            return .date
        case .int32:
            return .int32
        case .int64:
            return .int64
        case .timestamp:
            return .timestamp
        case .decimal128:
            return .decimal128
        case .minKey:
            return .minKey
        case .maxKey:
            return .maxKey
        case .regExp:
            return .regExp
        case .null:
            return .null
        }
    }
}
