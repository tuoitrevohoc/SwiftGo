//
//  BsonDecoder.swift
//  SwiftGo
//
//  Created by Tran Thien Khiem on 2019-07-17.
//
import NIO

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
    func decodeDocument(buffer: inout ByteBuffer) throws -> BsonDocument {
        
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
        case .string:
            return try readString(from: &buffer)
        case .objectId:
            return try readObjectId(from: &buffer)
        case .int32:
            return try readInt32(from: &buffer)
        default:
            throw BsonDecodeError.notSupported
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
    private func readString(from buffer: inout ByteBuffer) throws -> BsonValue {
        if let size = buffer.readInteger(endianness: .little, as: UInt32.self),
            let value = buffer.readString(length: Int(size - 1)) {
            buffer.moveReaderIndex(forwardBy: 1)
            
            return .string(value)
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
