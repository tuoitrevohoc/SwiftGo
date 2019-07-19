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
    
        expect(element: document.elements[0], hasName: "Hello", isString: "World")
        
    }
    
    /// Test read with Object Id
    func testObjectIdElement() throws {
        // _id: 5d308928e93d372b8e38cb4e
        // Hello: "World"
        let data: [UInt8] = [
            0x27, 0x00, 0x00, 0x00, // 0x27 = 39 bytes
            0x07, // object id
            0x5F, 0x69, 0x64, 0x00, // name = "_id"
            0x5D, 0x30, 0x89, 0x28, 0xE9, 0x3D, 0x37, 0x2B, 0x8E, 0x38, 0xCB, 0x4E, // 12 bytes object id
            0x02, // string
            0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x00, // name = "Hello"
            0x06, 0x00, 0x00, 0x00, // size = 6
            0x57, 0x6F, 0x72, 0x6C, 0x64, 0x00, // "World"
            0x00 // end byte zero
        ]
        
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(data.count, document.size)
        XCTAssertEqual(2, document.elements.count)
        
        expect(element: document.elements[0], hasName: "_id", isObjectId: [
            0x5d, 0x30, 0x89, 0x28, 0xe9, 0x3d, 0x37, 0x2b, 0x8e, 0x38, 0xcb, 0x4e
        ])
        
        expect(element: document.elements[1], hasName: "Hello", isString: "World")
    }
    
    
    func testInt32Element() throws {
        // _id: 5d308928e93d372b8e38cb4e
        // name: "Daniel"
        // age: 30
        let data: [UInt8] = [
            0x30, 0x00, 0x00, 0x00, 0x07, 0x5F, 0x69, 0x64, 0x00, 0x5D, 0x30,
            0x89, 0x28, 0xE9, 0x3D, 0x37, 0x2B, 0x8E, 0x38, 0xCB, 0x4E, 0x02,
            0x6E, 0x61, 0x6D, 0x65, 0x00, 0x07, 0x00, 0x00, 0x00, 0x44, 0x61,
            0x6E, 0x69, 0x65, 0x6C, 0x00, 0x10, 0x61, 0x67, 0x65, 0x00, 0x1E,
            0x00, 0x00, 0x00, 0x00
        ];
        
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(data.count, document.size)
        XCTAssertEqual(3, document.elements.count)
        
        expect(element: document.elements[0], hasName: "_id", isObjectId: [
            0x5d, 0x30, 0x89, 0x28, 0xe9, 0x3d, 0x37, 0x2b, 0x8e, 0x38, 0xcb, 0x4e
        ])
        
        expect(element: document.elements[1], hasName: "name", isString: "Daniel")
        expect(element: document.elements[2], hasName: "age", isInt32: 30)
    }
    
    func testNegativeInt32Element() throws {
        // _id: 5d308928e93d372b8e38cb4e
        // name: "Daniel"
        // age: -50
        let data: [UInt8] = [
            0x30, 0x00, 0x00, 0x00, 0x07, 0x5F, 0x69, 0x64, 0x00, 0x5D, 0x30,
            0x89, 0x28, 0xE9, 0x3D, 0x37, 0x2B, 0x8E, 0x38, 0xCB, 0x4E, 0x02,
            0x6E, 0x61, 0x6D, 0x65, 0x00, 0x07, 0x00, 0x00, 0x00, 0x44, 0x61,
            0x6E, 0x69, 0x65, 0x6C, 0x00, 0x10, 0x61, 0x67, 0x65, 0x00, 0xCE,
            0xFF, 0xFF, 0xFF, 0x00
        ];
        
        var buffer = allocator.buffer(capacity: data.count)
        buffer.writeBytes(data)
        
        let document = try decoder.decodeDocument(buffer: &buffer)
        
        XCTAssertEqual(data.count, document.size)
        XCTAssertEqual(3, document.elements.count)
        
        expect(element: document.elements[0], hasName: "_id", isObjectId: [
            0x5d, 0x30, 0x89, 0x28, 0xe9, 0x3d, 0x37, 0x2b, 0x8e, 0x38, 0xcb, 0x4e
        ])
        
        expect(element: document.elements[1], hasName: "name", isString: "Daniel")
        expect(element: document.elements[2], hasName: "age", isInt32: -50)
    }
    
    /// Expect to have a string
    /// - Parameter element: the element to check
    /// - Parameter name: the key
    /// - Parameter expectedValue: the value
    fileprivate func expect(element: BsonElement, hasName name: String, isInt32 expectedValue: Int32) {
        XCTAssertEqual(name, element.name)
        
        if case BsonValue.int32(let value) = element.value {
            XCTAssertEqual(expectedValue, value)
        } else {
            XCTFail("Expecting a int32 for \(element.name)")
        }
    }
    
    /// Expect to have a string
    /// - Parameter element: the element to check
    /// - Parameter name: the key
    /// - Parameter value: the value
    fileprivate func expect(element: BsonElement, hasName name: String, isString expectedValue: String) {
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
    fileprivate func expect(element: BsonElement, hasName name: String, isObjectId expectedValue: [UInt8]) {
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
