//
//  BsonValue.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

/// Bson value
public enum BsonValue {
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

extension BsonValue {
    
    /// Size of this item
    var size: Int {
        switch self {
        case .string(let value):
            return BsonSize.stringBoundary + value.count
        case .document(let document):
            return document.size
        case .array(let document):
            return document.size
        case .boolean:
            return BsonSize.booleanSize
        case .binary(let data, _):
            return data.count + 1
        case .code(let string, let scope):
            return BsonSize.stringBoundary + string.count + scope.size
        case .objectId(_):
            return BsonSize.objectIdSize
        case .date(_):
            return BsonSize.dateSize
        case .regExp(let string, let scope):
            return (BsonSize.stringBoundary << 1) + string.count + scope.count
        case .int32:
            return BsonSize.int32Size
        case .timestamp, .double, .int64:
            return BsonSize.int64Size
        case .decimal128:
            return BsonSize.decimal128Size
        case .null, .minKey, .maxKey:
            return 0
        }
    }
    
    /// Return a raw value
    var rawValue: Any? {
        switch self {
        case .double(let double):
            return double
        case .string(let string):
            return string
        case .document(let document):
            return document
        case .array(let array):
            return array
        case .binary(let data, _):
            return data
        case .code(let code, _):
            return code
        case .objectId(let data):
            return data
        case .boolean(let boolean):
            return boolean
        case .date(let date):
            return date
        case .int32(let integer):
            return integer
        case .int64(let integer):
            return integer
        case .timestamp(let timestamp):
            return timestamp
        case .decimal128:
            return nil
        case .minKey:
            return nil
        case .maxKey:
            return nil
        case .regExp(let pattern, _):
            return try? NSRegularExpression(pattern: pattern)
        case .null:
            return nil
        }
    }
        
    /// Convert a raw value to BSonValue
    /// - Parameter rawValue: raw value
    static func from(rawValue: Any?) -> BsonValue? {
        
        if rawValue == nil {
            return nil
        } else if let bsonConvertible = rawValue as? BsonConvertible {
            return bsonConvertible.toBsonValue()
        }
        
        return nil
    }
    
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
