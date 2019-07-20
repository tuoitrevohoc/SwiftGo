//
//  BsonDecoder.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//
import NIO
import Foundation

/// The error throws out of the bson decoder
enum BsonDecodeError: Error {
    case notSupported
    case invalidSize
    case invalidFormat
    case unexpectedEndOfStream
}

/// The simple bson decoder
struct BsonDecoder {
    
    /// size of the object id
    static let objectIdSize = 12
    
    static let boundaryLength = 5
    
    /// Decode bson document out of the buffer
    ///
    /// - Parameter buffer: the buffer
    func readDocument(buffer: inout ByteBuffer) throws -> BsonDocument {
        
        // read size of the document
        if let size = buffer.readInteger(endianness: .little, as: UInt32.self) {
            let start = buffer.readerIndex
            var current = start
            var elements = [BsonElement]()
            
            while current - start < Int(size) - BsonDecoder.boundaryLength {
                if let typeRaw = buffer.readInteger(endianness: .little, as: UInt8.self),
                    let type = BsonValueType(rawValue: typeRaw) {
                    let name = try readCString(from: &buffer)
                    let value = try readValue(type: type, from: &buffer)
                    let element = BsonElement(name: name, value: value)
                    
                    elements.append(element)
                    
                    current = buffer.readerIndex
                } else {
                    throw BsonDecodeError.invalidFormat
                }
            }
            
            buffer.moveReaderIndex(forwardBy: 1) // skip the last byte
            
            return BsonDocument(
                size: Int(size),
                elements: elements
            )
            
        } else {
            throw BsonDecodeError.invalidSize
        }
    }
    
    /// Read Value from buffer
    ///
    /// - Parameter type: the type of the field
    /// - Parameter buffer: the buffer
    private func readValue(type: BsonValueType, from buffer: inout ByteBuffer) throws -> BsonValue {
        
        switch type {
        case .double:
            return try readDouble(from: &buffer)
        case .string:
            return .string(try readString(from: &buffer))
        case .document:
            return .document(try readDocument(buffer: &buffer))
        case .array:
            return .array(try readDocument(buffer: &buffer))
        case .binary:
            return try readBinary(from: &buffer)
        case .date:
            return try readDate(from: &buffer)
        case .objectId:
            return try readObjectId(from: &buffer)
        case .boolean:
            return try readBoolean(from: &buffer)
        case .null:
            return .null
        case .regExp:
            return .regExp(try readCString(from: &buffer), scope: try readCString(from: &buffer))
        case .code:
            return .code(try readString(from: &buffer))
        case .codeWithScope:
            return .code(try readString(from: &buffer), scope: try readDocument(buffer: &buffer))
        case .int32:
            return try readInt32(from: &buffer)
        case .timestamp:
            return try readTimestamp(from: &buffer)
        case .int64:
            return try readInt64(from: &buffer)
        case .minKey:
            return .minKey
        case .maxKey:
            return .maxKey
        default:
            throw BsonDecodeError.notSupported
        }
    }
    
    /// Read timestamp from the buffer
    /// - Parameter buffer: buffer
    private func readTimestamp(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readInteger(endianness: .little, as: UInt64.self) {
            return .timestamp(value)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read date
    /// - Parameter from: read date from buffer
    private func readDate(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let data = buffer.readInteger(endianness: .little, as: UInt64.self) {
            return .date(Date(timeIntervalSince1970: TimeInterval(data)))
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the binary value out of byte buffer
    /// - parameter buffer: the buffer
    private func readBinary(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let size = buffer.readInteger(endianness: .little, as: UInt32.self),
            let subTypeRaw = buffer.readInteger(endianness: .little, as: UInt8.self),
            let subType = BinarySubType(rawValue: subTypeRaw),
            let data = buffer.readBytes(length: Int(size)) {
            return .binary(data, type: subType)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the boolean value out of the buffer
    /// - Parameter buffer: the buffer
    private func readBoolean(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readInteger(endianness: .little, as: UInt8.self) {
            return .boolean(value == 1)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the double out of the buffer
    /// - Parameter buffer: the buffer
    private func readDouble(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readBytes(length: 8),
            let data = value.withUnsafeBytes({
                $0.baseAddress?.load(as: Double.self)
            })
        {
            return .double(data)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the int64 out of the buffer
    /// - Parameter buffer: the buffer
    private func readInt64(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readInteger(endianness: .little, as: Int64.self) {
            return .int64(value)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the int32 out of the buffer
    /// - Parameter buffer: the buffer
    private func readInt32(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readInteger(endianness: .little, as: Int32.self) {
            return .int32(value)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read the object id out of the buffer
    /// - Parameter buffer: the buffer
    private func readObjectId(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let value = buffer.readBytes(length: BsonDecoder.objectIdSize) {
            return .objectId(value)
        } else {
            throw BsonDecodeError.unexpectedEndOfStream
        }
    }
    
    /// Read string out of the buffer
    /// - Parameter buffer: the buffer
    private func readString(from buffer: inout ByteBuffer) throws -> String {
        if let size = buffer.readInteger(endianness: .little, as: UInt32.self),
            let value = buffer.readString(length: Int(size - 1)) {
            buffer.moveReaderIndex(forwardBy: 1)
            
            return value
        } else {
            throw BsonDecodeError.invalidFormat
        }
    }
    
    /// Read a cstring from buffer
    /// - Parameter buffer: the buffer
    private func readCString(from buffer: inout ByteBuffer) throws -> String {
        if let view = buffer.viewBytes(at: buffer.readerIndex, length: buffer.readableBytes) {
        
            var size = 0
            let start = buffer.readerIndex
            while size < view.endIndex && view[start + size] > 0 {
                size = size + 1
            }
            
            if let result = buffer.readString(length: size) {
                buffer.moveReaderIndex(forwardBy: 1)
                
                return result
            } else {
                throw BsonDecodeError.invalidFormat
            }
            
        } else {
            throw BsonDecodeError.invalidFormat
        }
    }
}
