////
////  BsonSerializer.swift
////  SwiftGo
////
////  Created by Tran Thien Khiem on 2019-07-21.
////
//
//import Foundation
//
///// Encode one object to BsonElement
//class BsonEncoder: Encoder {
//    
//    /// the list of item
//    var count: Int = 0
//
//    /// Bson Element
//    private var element: BsonValue = .null
//    
//    /// THe coding path
//    var codingPath: [CodingKey] = []
//    
//    /// the user information
//    var userInfo: [CodingUserInfoKey : Any] = [:]
//    
//    /// The key parameter
//    ///
//    /// - Parameter type: the type
//    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        throw
//    }
//    
//    /// The unkey container
//    func unkeyedContainer() -> UnkeyedEncodingContainer {
//        return self
//    }
//    
//    /// The single value container
//    func singleValueContainer() -> SingleValueEncodingContainer {
//        return self
//    }
//}
//
//
///// Single value encoding container
//extension BsonEncoder: SingleValueEncodingContainer {
//
//    /// encode this value
//    func encodeNil() throws {
//        element = .null
//    }
//    
//    /// ENcode a value
//    /// - Parameter value: the value
//    func encode(_ value: Bool) throws {
//        element = .boolean(value)
//    }
//    
//    /// Encode a string
//    /// - Parameter value: the string value
//    func encode(_ value: String) throws {
//        element = .string(value)
//    }
//    
//    /// Encode a double
//    /// - Parameter value: the double value
//    func encode(_ value: Double) throws {
//        element = .double(value)
//    }
//    
//    /// ENcode a float value
//    /// - Parameter value: the float value
//    func encode(_ value: Float) throws {
//        element = .double(Double(value))
//    }
//    
//    /// Encode an integer value
//    /// - Parameter value: the value
//    func encode(_ value: Int) throws {
//        element = .int64(Int64(value))
//    }
//    
//    /// Encode a byte
//    /// - Parameter value: the value
//    func encode(_ value: Int8) throws {
//        element = .int32(Int32(value))
//    }
//    
//    /// Encode int 16 value
//    /// - Parameter value: the int 16 value
//    func encode(_ value: Int16) throws {
//        element = .int32(Int32(value))
//    }
//    
//    /// Encode a int32 value
//    /// - Parameter value: int 32 value
//    func encode(_ value: Int32) throws {
//        element = .int32(value)
//    }
//    
//    /// encode a int value
//    /// - Parameter value: the int value
//    func encode(_ value: Int64) throws {
//        element = .int64(value)
//    }
//    
//    /// Encode an uint value
//    /// - Parameter value: the uint
//    func encode(_ value: UInt) throws {
//        element = .timestamp(UInt64(value))
//    }
//    
//    /// ENcrypt
//    /// - Parameter value: the encrypt value
//    func encode(_ value: UInt8) throws {
//        element = .int32(Int32(value))
//    }
//    
//    /// Encrypt uint 36
//    /// - Parameter value: the uint32
//    func encode(_ value: UInt16) throws {
//        element = .int32(Int32(value))
//    }
//    
//    /// Encrypting a uint32 value
//    /// - Parameter value: uint32 value
//    func encode(_ value: UInt32) throws {
//        element = .int64(Int64(value))
//    }
//    
//    /// Encode a uint64 value
//    /// - Parameter value: uint64
//    func encode(_ value: UInt64) throws {
//        element = .timestamp(value)
//    }
//    
//    /// Encode a value to encoder
//    /// - Parameter value: the value
//    func encode<T>(_ value: T) throws where T : Encodable {
//    }
//}
//
//// set this to unkeyed encoding container
//    extension BsonEncoder: UnkeyedEncodingContainer {
//        
//        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
//        
//        }
//        
//        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
//        
//        }
//        
//        func superEncoder() -> Encoder {
//            return self
//        }
//    }
