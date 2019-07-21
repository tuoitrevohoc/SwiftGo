//
//  BsonValueType.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation

// possible value of bson value type
public enum BsonValueType: UInt8 {
    case double = 0x01
    case string = 0x02
    case document = 0x03
    case array = 0x04
    case binary = 0x05
    case undefined = 0x06 // deprecated
    case objectId = 0x07
    case boolean  = 0x08
    case date = 0x09
    case null = 0x0A
    case regExp = 0x0B
    case code = 0x0D
    case codeWithScope = 0x0F
    case int32 = 0x10
    case timestamp = 0x11
    case int64 = 0x12
    case decimal128 = 0x13
    case minKey = 0xFF
    case maxKey = 0x7F
}

