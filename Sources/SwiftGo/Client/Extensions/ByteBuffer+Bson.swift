//
//  ByteBuffer+Bson.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-20.
//

import Foundation
import NIO

// byte buffer
extension ByteBuffer {
    
    /// Write CString to the buffer
    ///
    /// - Parameter value: the value
    mutating func writeCString(_ value: String) {
        writeString(value)
        writeInteger(0 as UInt8)
    }
    
    /// Write bson document
    /// - Parameter document: the bson document
    mutating func write(document: BsonDocument) {
        writeInteger(UInt32(document.size), endianness: .little)
        
        for element in document.elements {
            let type = element.value.type
            writeInteger(UInt8(type.rawValue), endianness: .little)
            writeCString(element.name)
            write(value: element.value)
        }
        
        writeInteger(UInt8(0))
    }
    
    
    /// Write bson value
    /// - Parameter value: the value
    mutating func write(value: BsonValue) {
        switch value {
        case .double(let value):
            write(value)
        case .string(let value):
            write(bsonString: value)
        case .document(let value):
            write(document: value)
        case .array(let value):
            write(document: value)
        case .binary(let data, let subType):
            writeInteger(UInt32(data.count), endianness: .little)
            writeInteger(UInt8(subType.rawValue))
            writeBytes(data)
        case .objectId(let data):
            writeBytes(data)
        case .boolean(let value):
            if value {
                writeInteger(UInt8(1))
            } else {
                writeInteger(UInt8(0))
            }
        case .date(let date):
            writeInteger(UInt64(date.timeIntervalSince1970), endianness: .little)

        case .regExp(let value, let scope):
            writeCString(value)
            writeCString(scope)
        case .code(let code, let scope):
            write(bsonString: code)
            write(document: scope)
        case .int32(let value):
            writeInteger(UInt32(value), endianness: .little)
        case .timestamp(let value):
            writeInteger(UInt64(value), endianness: .little)
        case .int64(let value):
            writeInteger(Int64(value), endianness: .little)
        case .decimal128(let value):
            writeBytes(value)
        default:
            print("Don't need to write anything")
        }
    }
    
    /// WRite a double
    /// - Parameter value: the value
    mutating func write(_ value: Double) {
        var value = value
        
        let data = withUnsafeBytes(of: &value) {
            Array($0)
        }
        
        writeBytes(data)
    }
    
    /// Write bson string
    /// - Parameter bsonString: the string as input
    mutating func write(bsonString value: String) {
        writeInteger(UInt32(value.count + 1), endianness: .little)
        writeString(value)
        writeInteger(UInt8(0))
    }
}
