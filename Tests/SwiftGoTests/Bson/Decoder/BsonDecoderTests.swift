//
//  BsonDecoderTests.swift
//  CNIOAtomics
//
//  Created by Tran Thien Khiem on 2019-07-17.
//

import Foundation
import XCTest

@testable import NIO
@testable import SwiftGo

/// The bson decoder tests
final class BsonDecoderTests: XCTestCase {
    
    /// The document
    private let allocator = ByteBufferAllocator()
    
    /// The decoder
    private let decoder = BsonDecoder()
    
    /// Test read empty document
    func testReadEmptyDocument() throws {
        
        var buffer = allocator.buffer(capacity: 5)
        buffer.writeInteger(5 as UInt32, endianness: .little)
        buffer.writeInteger(0 as UInt8)
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(5, document.size)
        XCTAssertEqual(0, document.elements.count)
    }
    
    /// Test read document with 1 string element
    func testStringElement() throws {
        var buffer = allocator.buffer(capacity: 22)
        buffer.writeInteger(22 as UInt32, endianness: .little)
        
        buffer.writeInteger(BsonValueType.string.rawValue) // +1
        buffer.writeString("Hello") // + 6
        buffer.writeInteger(0 as UInt8)
        buffer.writeInteger(6 as UInt32, endianness: .little) // + 4
        buffer.writeString("World") // + 5
        buffer.writeInteger(0 as UInt8)
        buffer.writeInteger(0 as UInt8) // + 1
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(22, document.size)
        XCTAssertEqual(1, document.elements.count)
    
        expect(element: document.elements[0], hasName: "Hello", andValue: "World")
        
    }
    
    /// Test read with Object Id
    func testObjectIdElement() throws {
        // _id: 5d308928e93d372b8e38cb4e
        // Hello: "World"
        let data: [UInt8] = [
            0x27, 0x00, 0x00, 0x00, 0x07, 0x5F, 0x69, 0x64, 0x00, 0x5D, 0x30, 0x89, 0x28,
            0xE9, 0x3D, 0x37, 0x2B, 0x8E, 0x38, 0xCB, 0x4E, 0x02, 0x48, 0x65, 0x6C, 0x6C,
            0x6F, 0x00, 0x06, 0x00, 0x00, 0x00, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x00, 0x00
        ]
        
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(data.count, document.size)
        XCTAssertEqual(2, document.elements.count)
        
        expect(element: document.elements[0], hasName: "_id", andValue: [
            0x5d, 0x30, 0x89, 0x28, 0xe9, 0x3d, 0x37, 0x2b, 0x8e, 0x38, 0xcb, 0x4e
        ])
        
        expect(element: document.elements[1], hasName: "Hello", andValue: "World")
    }
    
    /// Expect to have a string
    /// - Parameter element: the element to check
    /// - Parameter name: the key
    /// - Parameter value: the value
    fileprivate func expect(element: BsonElement, hasName name: String, andValue expectedValue: String) {
        XCTAssertEqual(name, element.name)
        
        if case BsonValue.string(let value) = element.value {
            XCTAssertEqual(expectedValue, value)
        } else {
            XCTFail("Expecting a string for \(element.name)")
        }
    }
    
    /// Expect to have a ObjectId
    /// - Parameter element: the element to check
    /// - Parameter name: the key
    /// - Parameter value: the value
    fileprivate func expect(element: BsonElement, hasName name: String, andValue expectedValue: [UInt8]) {
        XCTAssertEqual(name, element.name)
        
        if case BsonValue.objectId(let value) = element.value {
            XCTAssertEqual(expectedValue, value)
        } else {
            XCTFail("Expecting a string for \(element.name)")
        }
    }
    
    /// Should throw invalid size if the size is not valid
    func testInvalidSize() throws {
        var buffer = allocator.buffer(capacity: 1)
        
        do {
            _ = try decoder.decodeDocument(buffer: &buffer)
            
            XCTFail("Should throw an error")
        } catch BsonDecodeError.invalidSize {
        } catch {
            XCTFail("Should throw invalidSize")
        }
    }
    
    /// Test
    static var allTests = [
        ("readEmptyDocument", testReadEmptyDocument),
        ("testInvalidSize", testInvalidSize),
        ("testStringElement", testStringElement),
        ("testObjectIdElement", testObjectIdElement)
    ]
}
